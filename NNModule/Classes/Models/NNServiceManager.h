//  NNServiceManager.h
//  Pods
//
//  Created by  XMFraker on 2017/12/21
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNServiceManager
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol NNServiceProtocol <NSObject>

@optional

/** 是否是单例 */
+ (BOOL)isSingleton;
/** 单例实现方法 */
+ (id)sharedInstance;

@end

@interface NNServiceManager : NSObject

/** 单例NNServiceManager */
+ (instancetype)sharedManager;

/**
 创建实现Protocol的实例

 @param protocol   实现协议
 @return id or nil
 */
- (nullable id)createServiceInstance:(Protocol *)protocol;

/**
 注册实现Protocol的实现类

 @param protocol  implClass需要实现的协议
 @param implClass 实现协议的类
 */
- (void)registerService:(Protocol *)protocol implClass:(Class)implClass;

@end

NS_ASSUME_NONNULL_END
