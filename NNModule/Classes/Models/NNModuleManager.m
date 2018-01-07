//  NNModuleManager.m
//  Pods
//
//  Created by  XMFraker on 2017/12/20
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNModuleManager
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNModuleManager.h"
#import "NNContext.h"
#import "NNTimeProfiler.h"
#import "NNModuleProtocol.h"
#import "UIApplication+NNModulized.h"

static NSString * const kNNModuleInfoNameKey = @"moduleName";
static NSString * const kNNModuleInfoLevelKey = @"moduleLevel";
static NSString * const kNNModuleInfoPriorityKey = @"momdulePriority";
static NSString * const kNNModuleInfoHasInitedKey = @"moduleInited";

static  NSString *kSetupSelector = @"modSetUp:";
static  NSString *kInitSelector = @"modInit:";
static  NSString *kSplashSeletor = @"modSplash:";
static  NSString *kTearDownSelector = @"modTearDown:";
static  NSString *kWillResignActiveSelector = @"modWillResignActive:";
static  NSString *kDidEnterBackgroundSelector = @"modDidEnterBackground:";
static  NSString *kWillEnterForegroundSelector = @"modWillEnterForeground:";
static  NSString *kDidBecomeActiveSelector = @"modDidBecomeActive:";
static  NSString *kWillTerminateSelector = @"modWillTerminate:";
static  NSString *kUnmountEventSelector = @"modUnmount:";
static  NSString *kQuickActionSelector = @"modQuickAction:";
static  NSString *kOpenURLSelector = @"modOpenURL:";
static  NSString *kDidReceiveMemoryWarningSelector = @"modDidReceiveMemoryWaring:";
static  NSString *kFailToRegisterForRemoteNotificationsSelector = @"modDidFailedRegisterRemoteNotification:";
static  NSString *kDidRegisterForRemoteNotificationsSelector = @"modDidRegisterRemoteNotifications:";
static  NSString *kDidReceiveRemoteNotificationsSelector = @"modDidReceiveRemoteNotification:";
static  NSString *kDidReceiveLocalNotificationsSelector = @"modDidReceiveLocalNotification:";
static  NSString *kWillPresentNotificationSelector = @"modWillPresentNotification:";
static  NSString *kDidReceiveNotificationResponseSelector = @"modDidReceiveNotificationResponse:";
static  NSString *kWillContinueUserActivitySelector = @"modWillContinueUserActivity:";
static  NSString *kContinueUserActivitySelector = @"modContinueUserActivity:";
static  NSString *kDidUpdateUserActivitySelector = @"modDidUpdateUserActivity:";
static  NSString *kFailToContinueUserActivitySelector = @"modDidFailContinueUserActivity:";
static  NSString *kHandleWatchKitExtensionRequestSelector = @"modHandleWatchKitExtensionRequest:";
static  NSString *kAppCustomSelector = @"modDidCustomEvent:";

@implementation NSMutableArray (NNModulePrivate)

- (id)moduleOfClass:(Class)moduleClass {
    
    if (!self.count) return nil;
    if (!moduleClass) return nil;
    __block NSInteger index = NSNotFound;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:moduleClass]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index != NSNotFound) return [self objectAtIndex:index];
    return nil;
}

@end

typedef NSMutableDictionary<NSNumber *, NSString *> NNSelectorEventMapper;
typedef NSMutableDictionary<NSNumber *, NSMutableArray<id<NNModuleProtocol>> *> NNModulesEventMapper;

@interface NNModuleManager ()

@property (strong, nonatomic) NSMutableArray *modules;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *moduleInfos;

@property (strong, nonatomic) NNSelectorEventMapper *selectorEventMapper;
@property (strong, nonatomic) NNModulesEventMapper *modulesEventMapper;

@end

@implementation NNModuleManager

#pragma mark - Life Cycle

+ (instancetype)sharedManager {
    static id manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NNModuleManager alloc] init];
    });
    return manager;
}

#pragma mark - Public

- (void)registerDynamicModule:(Class)moduleClass {
    
    [self registerDynamicModule:moduleClass shouldTriggetInitEvent:NO];
}

- (void)registerDynamicModule:(Class)moduleClass
       shouldTriggetInitEvent:(BOOL)shouldTrigger {
    
    [self storeModuleClass:moduleClass shouldTriggerInitEvent:shouldTrigger];
}

- (void)unregisterDyncmicModule:(Class)moduleClass {

    if (!moduleClass) return;
    
    // remove module info
    [self.moduleInfos filterUsingPredicate:[NSPredicate predicateWithFormat:@"%@!=%@", kNNModuleInfoNameKey, NSStringFromClass(moduleClass)]];
    
    // remove module instance
    id moduleInstance = [self.modules moduleOfClass:moduleClass];
    if (moduleInstance) {
        [self handleTriggerModuleTeardownEvent:moduleInstance customParams:nil];
        [self.modules removeObject:moduleInstance];
    }
    
    // remove module instance of event
    __weak typeof(self) wSelf = self;
    [self.modulesEventMapper enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSMutableArray<id<NNModuleProtocol>> * _Nonnull modules, BOOL * _Nonnull stop) {
        id moduleInstance = [modules moduleOfClass:moduleClass];
        if (moduleInstance) {
            __strong typeof(wSelf) self = wSelf;
            [self handleTriggerModuleEvent:NNModuleEventUnmount moduleInstance:moduleInstance customParams:nil];
            [modules removeObject:moduleInstance];
        }
    }];
}

- (void)registerCustomEvent:(NSUInteger)customEvent
             moduleInstance:(id)moduleInstance
                   selector:(SEL)selector {
    
    [self registerEvent:customEvent moduleInstance:moduleInstance selector:selector];
}

- (void)triggerEvent:(NSUInteger)event {
    
    [self triggerEvent:event customParams:nil];
}

- (void)triggerEvent:(NSUInteger)event customParams:(NSDictionary *)customParams {
    [self handleTriggerModuleEvent:event moduleInstance:nil customParams:customParams];
}

#pragma mark - Private

- (void)storeModuleClass:(Class)moduleClass
  shouldTriggerInitEvent:(BOOL)shouldTrigger {
    
    if (!moduleClass) return;
    if (![moduleClass conformsToProtocol:@protocol(NNModuleProtocol)]) return;
    

    __block BOOL isExists = NO;
    [self.modules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:moduleClass]) {
            isExists = YES;
            *stop = YES;
        }
    }];
    
    if (isExists) return;
    
    NSString *moduleName = NSStringFromClass(moduleClass);
    NSMutableDictionary *moduleInfo = [NSMutableDictionary dictionary];
    [moduleInfo setObject:moduleName forKey:kNNModuleInfoNameKey];
    [self.moduleInfos addObject:moduleInfo];
    
    id<NNModuleProtocol> instance = [[moduleClass alloc] init];
    [self.modules addObject:instance];
    [moduleInfo setObject:@(YES) forKey:kNNModuleInfoHasInitedKey];

    [self.modules sortUsingComparator:^NSComparisonResult(id<NNModuleProtocol>  _Nonnull obj1, id<NNModuleProtocol>  _Nonnull obj2) {
        if ([obj1 respondsToSelector:@selector(priority)]
            && [obj2 respondsToSelector:@selector(priority)]) {
            return [@([obj2 priority]) compare:@([obj1 priority])];
        }
        return NSOrderedSame;
    }];
    
    [self registerEventsWithModuleInstance:instance];
    
    if (shouldTrigger) {
        [self handleTriggerModuleEvent:NNModuleEventSetup
                        moduleInstance:instance
                          customParams:nil];
        [self handleTriggerModuleInitEvent:instance
                              customParams:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleTriggerModuleEvent:NNModuleEventSplash
                            moduleInstance:instance
                              customParams:nil];
        });
    }
}

- (void)registerEventsWithModuleInstance:(id<NNModuleProtocol>)moduleInstance {
    
    [self.selectorEventMapper enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [self registerEvent:key.integerValue moduleInstance:moduleInstance selector:NSSelectorFromString(obj)];
    }];
}

- (void)registerEvent:(NSUInteger)event
       moduleInstance:(id<NNModuleProtocol>)moduleInstance
             selector:(SEL)selector {
    
    if (!selector || ![moduleInstance respondsToSelector:selector]) return;
    
    if (![self.selectorEventMapper objectForKey:@(event)]) {
        [self.selectorEventMapper setObject:NSStringFromSelector(selector) forKey:@(event)];
    }
    
    if (![self.modulesEventMapper objectForKey:@(event)]) {
        [self.modulesEventMapper setObject:[NSMutableArray array] forKey:@(event)];
    }
    
    NSMutableArray *eventModules = [self.modulesEventMapper objectForKey:@(event)];
    if (![eventModules containsObject:moduleInstance]) {
        [eventModules addObject:moduleInstance];
        
        [eventModules sortUsingComparator:^NSComparisonResult(id<NNModuleProtocol>  _Nonnull obj1, id<NNModuleProtocol>  _Nonnull obj2) {
            if ([obj1 respondsToSelector:@selector(priority)]
                && [obj2 respondsToSelector:@selector(priority)]) {
                return [@([obj2 priority]) compare:@([obj1 priority])];
            }
            return NSOrderedSame;
        }];
    }
}

- (void)handleTriggerModuleEvent:(NSUInteger)event
                  moduleInstance:(id<NNModuleProtocol>)moduleInstance
                    customParams:(NSDictionary *)customParams {

    switch (event) {
        case NNModuleEventInit:
            [self handleTriggerModuleInitEvent:moduleInstance customParams:customParams];
            break;
        case NNModuleEventTearDown:
            [self handleTriggerModuleTeardownEvent:moduleInstance customParams:customParams];
            break;
        default:
            [self handleTriggerModuleEvent:event
                            moduleInstance:moduleInstance
                                  selector:nil
                              customParams:customParams];
            break;
    }
}

- (void)handleTriggerModuleInitEvent:(id<NNModuleProtocol>)moduleInstance
                        customParams:(NSDictionary *)customParams {

    NNContext *context = [[UIApplication sharedApplication].context copy];
    context.customParams = customParams;
    context.customEvent = NNModuleEventInit;

    NSArray<id<NNModuleProtocol>> *targets = [self modulesOfEvent:NNModuleEventInit defaultInstance:moduleInstance];
    if (!targets || !targets.count) return;

    for (id<NNModuleProtocol> target in targets) {
        
        void(^delayHandler)(void) = ^ {
            if ([target respondsToSelector:@selector(modInit:)]) {
                [target modInit:context];
            }
        };
        
        [[NNTimeProfiler sharedProfiler] recordEventTime:[NSString stringWithFormat:@"%@ --- modInit:", [target class]]];
        
        if ([target respondsToSelector:@selector(isAsync)] && [target isAsync]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                delayHandler();
            });
        } else {
            delayHandler();
        }
    }
}

- (void)handleTriggerModuleTeardownEvent:(id<NNModuleProtocol>)moduleInstance
                            customParams:(NSDictionary *)customParams {

    NNContext *context = [[UIApplication sharedApplication].context copy];
    context.customParams = customParams;
    context.customEvent = NNModuleEventTearDown;

    NSArray<id<NNModuleProtocol>> *targets = [self modulesOfEvent:NNModuleEventTearDown defaultInstance:moduleInstance];
    if (!targets || !targets.count) return;
    
    // reverse teardown modules
    for (id<NNModuleProtocol> target in [targets reverseObjectEnumerator]) {
        if ([target respondsToSelector:@selector(modTearDown:)]) {
            [target modTearDown:context];
        }
    }
}

- (void)handleTriggerModuleEvent:(NNModuleEvent)event
                  moduleInstance:(id<NNModuleProtocol>)moduleInstance
                        selector:(SEL)selector
                    customParams:(NSDictionary *)customParams {
    
    NNContext *context = [[UIApplication sharedApplication].context copy];
    context.customParams = customParams;
    context.customEvent = event;
    SEL sel = selector ? : NSSelectorFromString([self.selectorEventMapper objectForKey:@(event)]);
    
    if (!sel) return;
    
    NSArray<id<NNModuleProtocol>> *targets = [self modulesOfEvent:event defaultInstance:moduleInstance];
    if (!targets || !targets.count) return;

    [targets enumerateObjectsUsingBlock:^(id<NNModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:sel withObject:context];
#pragma clang diagnostic pop
        }
        [[NNTimeProfiler sharedProfiler] recordEventTime:[NSString stringWithFormat:@"%@ --- %@", [obj class], NSStringFromSelector(sel)]];
    }];
}


- (NSArray<id<NNModuleProtocol>> *)modulesOfEvent:(NSUInteger)event
                                  defaultInstance:(id<NNModuleProtocol>)defaultInstance {
    
    if (defaultInstance) return @[defaultInstance];
    return [self.modulesEventMapper objectForKey:@(event)];
}

#pragma mark - Getter

- (NSMutableArray *)modules {
    
    if (!_modules) {
        _modules = [NSMutableArray array];
    }
    return _modules;
}

- (NSMutableArray *)moduleInfos {
    
    if (!_moduleInfos) {
        _moduleInfos = [NSMutableArray array];
    }
    return _moduleInfos;
}

- (NSMutableDictionary *)modulesEventMapper {
    
    if (!_modulesEventMapper) {
        _modulesEventMapper = [NSMutableDictionary dictionary];
    }
    return _modulesEventMapper;
}

- (NSMutableDictionary<NSNumber *, NSString *> *)selectorEventMapper {
    
    if (!_selectorEventMapper) {
        _selectorEventMapper = @{
                               // app life cycle selectors
                               @(NNModuleEventSetup) : kSetupSelector,
                               @(NNModuleEventInit) : kInitSelector,
                               @(NNModuleEventTearDown) : kTearDownSelector,
                               @(NNModuleEventSplash) : kSplashSeletor,
                               @(NNModuleEventWillResignActive) : kWillResignActiveSelector,
                               @(NNModuleEventDidEnterBackground) : kDidEnterBackgroundSelector,
                               @(NNModuleEventWillEnterForgeground) : kWillEnterForegroundSelector,
                               @(NNModuleEventDidBecomeActive) : kDidBecomeActiveSelector,
                               @(NNModuleEventWillTerminate) : kWillTerminateSelector,
                               @(NNModuleEventUnmount) : kUnmountEventSelector,
                               @(NNModuleEventOpenURL) : kOpenURLSelector,
                               @(NNModuleEventReceiveMemoryWarning) : kDidReceiveMemoryWarningSelector,
                               
                               // notification selectors
                               @(NNModuleEventReceiveRemoteNotification) : kDidReceiveRemoteNotificationsSelector,
                               @(NNModuleEventWillPresentNotification) : kWillPresentNotificationSelector,
                               @(NNModuleEventReceiveNotificationResponse) : kDidReceiveNotificationResponseSelector,
                               @(NNModuleEventFailToRegisterForRemoteNotifications) : kFailToRegisterForRemoteNotificationsSelector,
                               @(NNModuleEventRegisterRemoteNotification) : kDidRegisterForRemoteNotificationsSelector,
                               @(NNModuleEventReceiveLocalNotification) : kDidReceiveLocalNotificationsSelector,
                               
                               // user activity selectors
                               @(NNModuleEventWillContinueUserActivity) : kWillContinueUserActivitySelector,
                               @(NNModuleEventContinueUserActivity) : kContinueUserActivitySelector,
                               @(NNModuleEventFailedToContinueUserActivity) : kFailToContinueUserActivitySelector,
                               @(NNModuleEventUpdateUserActivity) : kDidUpdateUserActivitySelector,
                               
                               // 3D-Touch
                               @(NNModuleEventQuickAction) : kQuickActionSelector,
                               
                               // iWatch
                               @(NNModuleEventHandleWatchKitExtensionRequest) : kHandleWatchKitExtensionRequestSelector,
                               
                               // custom
                               @(NNModuleEventCustom) : kAppCustomSelector,
                               }.mutableCopy;
    }
    return _selectorEventMapper;
}

@end

