//  NNRouter.h
//  Pods
//
//  Created by  XMFraker on 2017/12/21
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNRouter
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kNNRURLCallServiceSelectorHost = @"call.service.selector.router";
static NSString *const kNNRURLResiterServiceHost = @"register.service.router";
static NSString *const kNNRURLResiterModuleHost = @"register.module.router";
static NSString *const kNNRURLEnterViewControllerHost = @"enter.viewcontroller.router";

typedef void(^NNRouterCompletionHandler)(id __nullable target, id __nullable result);
typedef id _Nullable (^NNRPathComponentCustomHandler)(id __nullable target, NSDictionary<NSString *, id> * __nullable params);

/**
 *  通过URL方式调用service or push(modal) viewController
 *  URL支持格式如下
 *  call service selector:
 *  your scheme://call.service.selector.router/your_registered_component.protocol.selector/...?params={}(url encoded)
 *
 *  enter view controller:
 *  your scheme://enter.viewcontroller.router/your_registered_component.protocol.push(modal)/...?params={}(url encoded)
 *
 *  params = {"your_registered_component":{xxxxx:xxxxx},.....}(value should be urlencoded)
 *  @warning using @1,@2,@3... as param key when call service selector
 **/
@interface NNRouter : NSObject

/** key of router */
@property (copy, nonatomic, readonly)   NSString *scheme;

/**
 注册PathComponent,implClass

 @param component     path component key to find implClass
 @param implClass     implClass will be create instance
 */
- (void)registerPathComponent:(NSString *)component
                    implClass:(Class)implClass;

/**
 注册PathComponent,implClass
 
 @param component     path component key to find implClass
 @param implClass     implClass will be create instance
 @param customHandler customHandler when called URL
 */
- (void)registerPathComponent:(NSString *)component
                    implClass:(Class)implClass
                customHandler:(nullable NNRPathComponentCustomHandler)customHandler;

/** 全局公用的router */
+ (instancetype)globalRouter;

/**
 根据scheme生成对应NNRouter 实例

 @param scheme key of router
 @return NNRouter 实例 or nil
 */
+ (nullable instancetype)routerOfScheme:(NSString *)scheme;

/** 移除所有已注册的NNRouter示例 */
+ (void)unregisterAllRouters;

/**
 移除已注册的NNRouter示例

 @param scheme key of router
 */
+ (void)unregisterRouterOfScheme:(NSString *)scheme;

/**
 URL是否可以被打开

 @param URL  需要被判断的URL
 @return YES or NO
 */
+ (BOOL)canOpenURL:(NSURL *)URL;

/**
 打开URL

 @param URL  需要被打开的URL
 @return YES or NO
 */
+ (BOOL)openURL:(NSURL *)URL;

/**
 打开URL

 @param URL         需要被打开的URL
 @param userInfo    自定义参数
 @return YES or NO
 */
+ (BOOL)openURL:(NSURL *)URL
       userInfo:(nullable NSDictionary *)userInfo;

/**
 打开URL

 @param URL         需要被打开的URL
 @param userInfo    自定义参数
 @param completionHandler 完成回调
 @return YES or NO
 */
+ (BOOL)openURL:(NSURL *)URL
           userInfo:(nullable NSDictionary *)userInfo
  completionHandler:(nullable NNRouterCompletionHandler)completionHandler;


@end

@interface NNRouter (NNRouterDeprecated)
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
