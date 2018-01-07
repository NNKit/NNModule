//  NNContext.h
//  Pods
//
//  Created by  XMFraker on 2017/12/20
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNContext
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NNEnvironment) {
    NNEnvironmentDev = 0,
    NNEnvironmentUat,
    NNEnvironmentDis,
};

@class NNOpenURLItem;
@class NNWatchItem;
@class NNNotificationItem;
@class NNUserActivityItem;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
@class NNShortcutItem;
#endif

@interface NNContext : NSObject <NSCopying>

@property (assign, nonatomic) NNEnvironment env;
@property (strong, nonatomic) NSUserDefaults *config;

/** 自定义事件值 > 1000 */
@property (assign, nonatomic) NSUInteger customEvent;
/** 自定义传递参数 */
@property (copy, nonatomic)   NSDictionary *customParams;
/** 启动参数 */
@property (copy, nonatomic)   NSDictionary  *launchOptions;

@property (strong, nonatomic) NNNotificationItem *notificationItem;
@property (strong, nonatomic) NNOpenURLItem *URLItem;
@property (strong, nonatomic) NNUserActivityItem *userActivityItem;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
@property (strong, nonatomic) NNShortcutItem *shortcutItem;
#endif
@property (strong, nonatomic) NNWatchItem *watchItem;

@end
