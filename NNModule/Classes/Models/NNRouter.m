//  NNRouter.m
//  Pods
//
//  Created by  XMFraker on 2017/12/21
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNRouter
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNRouter.h"
#import "NNModuleProtocol.h"
#import "NNServiceManager.h"
#import "NNModuleManager.h"

#import <objc/runtime.h>

@class  NNRPathComponent;
typedef NSMutableDictionary<NSString *, NNRouter *> NNRouterSchemeMapper;
typedef NSMutableDictionary<NSString *, NNRPathComponent *> NNRouterPathComponentMapper;
typedef NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> NNRouterPathComponentParamMapper;

static NSString *kNNGloablRouterScheme = nil;
static NNRouterSchemeMapper *kNNRouterSchemeMapper = nil;

static NSString *const kNNRURLSubPathSplitPattern = @".";

typedef NS_ENUM(NSUInteger, NNRViewControllerEnterMode) {
    NNRViewControllerEnterModePush = 0,
    NNRViewControllerEnterModeModal,
};

typedef NS_ENUM(NSUInteger, NNRURLUsage) {
    NNRURLUsageUnknown,
    NNRURLUsageCallService,
    NNRURLUsageEnterViewController,
    NNRURLUsageRegisterService,
    NNRURLUsageRegisterModule
};


@implementation NSInvocation (NNRouterPrivate)

#define return_number_value(_type_) \
{   \
_type_ ret;  \
[self getReturnValue:&ret]; \
return @(ret); \
}

- (id)returnValueAsObject {
    
    if (self.methodSignature.methodReturnLength == 0) return nil;
    const char *methodReturnType = [[self methodSignature] methodReturnType];
    
    switch (*methodReturnType) {
        case 'v': //fall through
        case 'V': return nil;
        case 'c': return_number_value(int8_t);
        case 'C': return_number_value(uint8_t);
        case 'i': return_number_value(int32_t);
        case 'I': return_number_value(uint32_t);
        case 's': return_number_value(int16_t);
        case 'S': return_number_value(uint16_t);
        case 'f': return_number_value(float);
        case 'd': return_number_value(double);
        case 'B': return_number_value(BOOL);
        case 'l': return_number_value(long);
        case 'L': return_number_value(unsigned long);
        case 'q': return_number_value(long long);
        case 'Q': return_number_value(unsigned long long);
        case '@':
        case '#':
        {
            void *ret;
            [self getReturnValue:&ret];
            return (__bridge id)ret;
        }
        default:
            return nil;
    }
    return nil;
}

@end

@implementation NNRouter (NNRouterUtils)

+ (NNRURLUsage)usageOfURLPattern:(NSString *)pattern {
    
    if (!pattern.length) return NNRURLUsageUnknown;
    NSString *lowerPattern = [pattern lowercaseString];
    if ([kNNRURLCallServiceSelectorHost isEqualToString:lowerPattern]) {
        return NNRURLUsageCallService;
    } else if ([kNNRURLResiterServiceHost isEqualToString:lowerPattern]) {
        return NNRURLUsageRegisterService;
    } else if ([kNNRURLResiterModuleHost isEqualToString:lowerPattern]) {
        return NNRURLUsageRegisterModule;
    } else if ([kNNRURLEnterViewControllerHost isEqualToString:lowerPattern]) {
        return NNRURLUsageEnterViewController;
    } else {
        return NNRURLUsageUnknown;
    }
}

+ (NNRViewControllerEnterMode)viewControllerEnterModeOfURLPattern:(NSString *)pattern {

    if (!pattern.length) return NNRViewControllerEnterModePush;
    NSString *lowerPattern = [pattern lowercaseString];
    if ([lowerPattern isEqualToString:@"modal"]) return NNRViewControllerEnterModeModal;
    return NNRViewControllerEnterModePush;
}

+ (NSDictionary<NSString *, NSString *> *)queryParamsOfURL:(NSURL *)URL {
    
    if (!URL) return nil;
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:URLComponents.queryItems.count];
    for (NSURLQueryItem *item in URLComponents.queryItems) {
        if (item.name.length && item.value.length) [params setObject:item.value forKey:item.name];
    }
    return [params copy];
}

+ (NNRouterPathComponentParamMapper *)paramsOfJSONString:(NSString *)JSONString {
    
    if (!JSONString.length) return nil;
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    if (!JSONData) return nil;
    NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:JSONData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    return ret;
}


+ (void)handleEnterViewController:(__kindof UIViewController *)viewController
                        enterMode:(NNRViewControllerEnterMode)mode
                         animated:(BOOL)animated {
    
    UIViewController *topViewController = [NNRouter topViewController];
    switch (mode) {
        case NNRViewControllerEnterModeModal:
            [topViewController presentViewController:viewController animated:animated completion:NULL];
            break;
        case NNRViewControllerEnterModePush:
        default:
            [topViewController.navigationController pushViewController:viewController animated:animated];
            break;
    }
}

+ (id)handleSafePerformSelector:(SEL)selector
                      forTarget:(id)target
                     withParams:(NSDictionary *)params {
    
    NSMethodSignature *sig = [target methodSignatureForSelector:selector];
    if (!sig) return nil;
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    if (!inv) return nil;
    [inv setTarget:target];
    [inv setSelector:selector];
    
    NSArray<NSNumber *> *keys = [params.allKeys sortedArrayUsingSelector:@selector(compare:)]; //sort arguments
    if ((keys.count + 2) != inv.methodSignature.numberOfArguments) return nil; // error arguments count
    [keys enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id param = [params objectForKey:obj];
        [inv setArgument:&param atIndex:(idx + 2)];
    }];
    [inv invoke];
    return [inv returnValueAsObject];
}


+ (NSDictionary<NSString *, id> *)solveParamsWithURLParams:(NSDictionary *)URLParams
                                           componentParams:(NSDictionary *)componentParams
                                                 component:(NSString *)component
                                                  forClass:(Class)implClass {
    
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    if ([URLParams objectForKey:component]) {
        [ret addEntriesFromDictionary:[URLParams objectForKey:component]];
    } else {
        [ret addEntriesFromDictionary:URLParams];
    }
    
    if ([componentParams objectForKey:component]) {
        [ret addEntriesFromDictionary:[componentParams objectForKey:component]];
    } else {
        [ret addEntriesFromDictionary:componentParams];
    }

    if (implClass) {
        [ret.allKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            objc_property_t prop = class_getProperty(implClass, obj.UTF8String);
            if (!prop) {
                // 移除class 未实现的参数
                [ret removeObjectForKey:obj];
            } else {
                NSString *propAttr = [[NSString alloc] initWithCString:property_getAttributes(prop) encoding:NSUTF8StringEncoding];
                NSRange range = [propAttr rangeOfString:@"(?<=T@\")(.*)(?=\",)" options:NSRegularExpressionSearch];
                if (range.location != NSNotFound) {
                    NSString *propClassName = [propAttr substringWithRange:range];
                    Class propClass = NSClassFromString(propClassName);
                    id value = [ret objectForKey:obj];
                    if ([propClass isSubclassOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]]) {
                        [ret setObject:[NSString stringWithFormat:@"%@", value] forKey:obj];
                    } else if ([propClass isSubclassOfClass:[NSNumber class]] && [value isKindOfClass:[NSString class]]) {
                        [ret setObject:@(((NSString *)value).doubleValue) forKey:obj];
                    } else if (![value isKindOfClass:propClass]) {
                        // 移除类型不匹配参数
                        [ret removeObjectForKey:obj];
                    }
                }
            }
        }];
    }
    return [ret copy];
}

+ (UIViewController *)topViewController {
    
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (viewController) {
        if ([viewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tbvc = (UITabBarController*)viewController;
            viewController = tbvc.selectedViewController;
        } else if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nvc = (UINavigationController*)viewController;
            viewController = nvc.topViewController;
        } else if (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        } else if ([viewController isKindOfClass:[UISplitViewController class]] &&
                   ((UISplitViewController *)viewController).viewControllers.count > 0) {
            UISplitViewController *svc = (UISplitViewController *)viewController;
            viewController = svc.viewControllers.lastObject;
        } else  {
            return viewController;
        }
    }
    return viewController;
}

@end


@interface NNRPathComponent : NSObject

@property (copy, nonatomic)   NSString *key;
@property (strong, nonatomic) Class implClass;
@property (copy, nonatomic)   NSDictionary<NSString *, id> *params;
@property (copy, nonatomic)   NNRPathComponentCustomHandler handler;

@end

@implementation NNRPathComponent
@end

@interface NNRouter ()

@property (strong, nonatomic) NNRouterPathComponentMapper *pathComponentMapper;
@property (copy, nonatomic)   NSString *scheme;

@end

@implementation NNRouter

#pragma mark - Life Cycle

+ (instancetype)globalRouter {
    if (!kNNGloablRouterScheme.length) kNNGloablRouterScheme = [[NSBundle mainBundle] bundleIdentifier];
    if (!kNNGloablRouterScheme.length) kNNGloablRouterScheme = @"com.xmfraker.nnrouter";
    return [self routerOfScheme:kNNGloablRouterScheme];
}

+ (instancetype)routerOfScheme:(NSString *)scheme {
    
    if (!scheme.length) return nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kNNRouterSchemeMapper = [NSMutableDictionary dictionary];
    });
    
    NNRouter *router = [kNNRouterSchemeMapper objectForKey:scheme];
    if (!router) {
        router = [[self alloc] init];
        router.scheme = scheme;
        router.pathComponentMapper = [NSMutableDictionary dictionary];
        [kNNRouterSchemeMapper setObject:router forKey:scheme];
    }
    return router;
}

#pragma mark - Public

- (void)registerPathComponent:(NSString *)component implClass:(Class)implClass {
    
    [self registerPathComponent:component implClass:implClass customHandler:nil];
}

- (void)registerPathComponent:(NSString *)component
                    implClass:(Class)implClass
                customHandler:(NNRPathComponentCustomHandler)customHandler {
    
    NSAssert(component.length, @"component should not be nil");
    if (!component.length) return;
    
    NNRPathComponent *pathComponent = [[NNRPathComponent alloc] init];
    pathComponent.key = component;
    pathComponent.implClass = implClass;
    pathComponent.handler = customHandler;
    [self.pathComponentMapper setObject:pathComponent forKey:component];
}

#pragma mark - Class

+ (void)unregisterAllRouters {
 
    [kNNRouterSchemeMapper removeAllObjects];
}

+ (void)unregisterRouterOfScheme:(NSString *)scheme {
    
    if (!scheme.length) return;
    [kNNRouterSchemeMapper removeObjectForKey:scheme];
}

/// ========================================
/// @name   URL Operation
/// ========================================

+ (BOOL)canOpenURL:(NSURL *)URL {
    
    if (!URL) return NO;
    if (!URL.scheme.length) return NO;
    if (!URL.pathComponents.count) return NO;
    
    NNRouter *router = [NNRouter routerOfScheme:URL.scheme];
    
    NNRURLUsage usage = [NNRouter usageOfURLPattern:URL.host];
    if (usage == NNRURLUsageUnknown) return NO;
    
    BOOL flag = NO;
    for (NSString *component in URL.pathComponents) {
        
        if ([component isEqualToString:@"/"]) continue;
        
        NSArray<NSString *> *subPaths = [component componentsSeparatedByString:kNNRURLSubPathSplitPattern];
        NSString *key = [subPaths firstObject];
        NNRPathComponent *pathComponent = [router.pathComponentMapper objectForKey:key];
        if (pathComponent) return YES;
        
        Protocol *protocol = subPaths.count >= 2 ? NSProtocolFromString([subPaths objectAtIndex:1]) : nil;
        SEL selector = subPaths.count >= 3 ? NSSelectorFromString([subPaths objectAtIndex:2]) : nil;
        Class implClass = NSClassFromString(key);
        if (!implClass) continue;
        
        switch (usage) {
            case NNRURLUsageCallService:
                if (!protocol || !selector) continue;
                if ([implClass conformsToProtocol:protocol]
                    && [implClass instancesRespondToSelector:selector]) flag = YES;
                break;
            case NNRURLUsageRegisterModule:
                if ([implClass conformsToProtocol:@protocol(NNModuleProtocol)]) flag = YES;
                break;
            case NNRURLUsageRegisterService:
                if (![implClass conformsToProtocol:@protocol(NNServiceProtocol)]) continue;
                if (protocol && [implClass conformsToProtocol:protocol]) flag = YES;
                break;
            case NNRURLUsageEnterViewController:
                if ([implClass isSubclassOfClass:[UIViewController class]]) flag = YES;
                break;
            case NNRURLUsageUnknown:
                break;
        }
        if (flag) return flag;
    }
    return flag;
}

+ (BOOL)openURL:(NSURL *)URL {
    return [self openURL:URL userInfo:nil completionHandler:nil];
}

+ (BOOL)openURL:(NSURL *)URL userInfo:(NSDictionary *)userInfo {
    return [self openURL:URL userInfo:userInfo completionHandler:nil];
}

+ (BOOL)openURL:(NSURL *)URL
           userInfo:(NSDictionary *)userInfo
  completionHandler:(NNRouterCompletionHandler)completionHandler {
    
    if (![self canOpenURL:URL]) return NO;
    
    NNRouter *router = [NNRouter routerOfScheme:URL.scheme];
    NNRURLUsage usage = [NNRouter usageOfURLPattern:URL.host];
    
    NSDictionary<NSString *, NSString *> *queryParams = [NNRouter queryParamsOfURL:URL];
    NSString *componentParamString = [queryParams objectForKey:@"params"];
    NNRouterPathComponentParamMapper *componentParams = [NNRouter paramsOfJSONString:componentParamString];
    
    for (NSString *pathComponent in URL.pathComponents) {
       
        if ([pathComponent isEqualToString:@"/"]) continue;
        
        NSArray<NSString *> *subPaths = [pathComponent componentsSeparatedByString:kNNRURLSubPathSplitPattern];
        // 解析获取Class,Protocol,PathComponent
        NSString *key = [subPaths firstObject];
        NNRPathComponent *component = [router.pathComponentMapper objectForKey:key];
        Class implClass = component.implClass ? : NSClassFromString(key);
        Protocol *protocol = subPaths.count >= 2 ? NSProtocolFromString([subPaths objectAtIndex:1]) : nil;
        
        // 解析获取参数
        NSDictionary *finalParams = [NNRouter solveParamsWithURLParams:userInfo
                                                       componentParams:componentParams
                                                             component:key
                                                              forClass:usage == NNRURLUsageCallService ? nil : implClass];
        
        id target = nil;
        id retValue = nil;
        
        if (component.handler) {
            if (protocol) target = [[NNServiceManager sharedManager] createServiceInstance:protocol];
            if (!target) target = [[implClass alloc] init];
            retValue = component.handler(target, finalParams);
            if (completionHandler) completionHandler(target, retValue);
            continue;
        }

        switch (usage) {
            case NNRURLUsageRegisterService:
                [[NNServiceManager sharedManager] registerService:protocol implClass:implClass];
                break;
            case NNRURLUsageRegisterModule:
                [[NNModuleManager sharedManager] registerDynamicModule:implClass];
                break;
            case NNRURLUsageCallService:
            {
                SEL selector = subPaths.count >= 3 ? NSSelectorFromString([subPaths objectAtIndex:2]) : nil;
                if (protocol) target = [[NNServiceManager sharedManager] createServiceInstance:protocol];
                if (!target) target = [[implClass alloc] init];
                retValue = [NNRouter handleSafePerformSelector:selector forTarget:target withParams:finalParams];
            }
                break;
            case NNRURLUsageEnterViewController:
            {
                NNRViewControllerEnterMode mode = [NNRouter viewControllerEnterModeOfURLPattern:URL.fragment];
                if (subPaths.count >= 3) mode = [NNRouter viewControllerEnterModeOfURLPattern:[subPaths objectAtIndex:2]];
                if (protocol) target = [[NNServiceManager sharedManager] createServiceInstance:protocol];
                if (!target) target = [[implClass alloc] init];
                if (target && finalParams.count) {
                    [finalParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        [target setValue:obj forKey:key];
                    }];
                }
                BOOL animated = ([URL.pathComponents lastObject] == pathComponent);
                [NNRouter handleEnterViewController:target enterMode:mode animated:animated];
            }
                break;
            case NNRURLUsageUnknown: break;
        }
        if (completionHandler) completionHandler(target, retValue);
    }
    return YES;
}

@end
