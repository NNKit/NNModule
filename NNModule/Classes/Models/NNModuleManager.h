//  NNModuleManager.h
//  Pods
//
//  Created by  XMFraker on 2017/12/20
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNModuleManager
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <Foundation/Foundation.h>

#define NN_MODULE_EXPORT(async) \
+ (void)load { [[NNModuleManager sharedManager] registerDynamicModule:[self class]]; } \
- (BOOL)isAsync { return [[NSString stringWithUTF8String:#async] boolValue]; }

NS_ASSUME_NONNULL_BEGIN

@interface NNModuleManager : NSObject

/** NNModuleManager 单例 */
+ (instancetype)sharedManager;

/**
 注册模块

 @param moduleClass Class of Module
 */
- (void)registerDynamicModule:(Class)moduleClass;

/**
 注册模块

 @param moduleClass   Class of Module
 @param shouldTrigger 是否触发 modInit:
 */
- (void)registerDynamicModule:(Class)moduleClass
       shouldTriggetInitEvent:(BOOL)shouldTrigger;

/**
 注销模块

 @param moduleClass   Class of Module
 */
- (void)unregisterDyncmicModule:(Class)moduleClass;

/**
 注册模块自定义时间

 @param customEvent     自定义事件tag >1000
 @param moduleInstance  Instance of Module
 @param selector        事件方法
 */
- (void)registerCustomEvent:(NSUInteger)customEvent
             moduleInstance:(id)moduleInstance
                   selector:(SEL)selector;

/**
 触发事件

 @param event 事件tag
 */
- (void)triggerEvent:(NSUInteger)event;

/**
 触发事件

 @param event           事件tag
 @param customParams    自定义参数
 */
- (void)triggerEvent:(NSUInteger)event customParams:(nullable NSDictionary *)customParams;

@end

NS_ASSUME_NONNULL_END
