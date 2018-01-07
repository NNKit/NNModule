//  NNAppDelegate.h
//  Pods
//
//  Created by  XMFraker on 2017/12/20
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNAppDelegate
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    #import <UserNotifications/UserNotifications.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NNModulizedDelegate : UIResponder <UIApplicationDelegate>

@end

/// ========================================
/// @name   通知相关定义
/// ========================================

typedef void(^NNNotificationResultHandler)(UIBackgroundFetchResult result);

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
typedef void(^NNNotificationCompletionHandler)(void);
typedef void(^NNNotificationPresentationOptionsHandler)(UNNotificationPresentationOptions options) NS_AVAILABLE_IOS(10.0);
#endif

@interface NNNotificationItem : NSObject

@property (strong, nonatomic, nullable) NSError *error;
@property (copy, nonatomic, nullable)   NSData *deviceToken;
@property (copy, nonatomic, nullable)   NSDictionary *userInfo;
@property (strong, nonatomic, nullable) UILocalNotification *localNotification;
@property (copy, nonatomic, nullable)   NNNotificationResultHandler resultHandler;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@property (strong, nonatomic, nullable) UNNotification *notification  NS_AVAILABLE_IOS(10.0);
@property (strong, nonatomic, nullable) UNNotificationResponse *notificationResponse  NS_AVAILABLE_IOS(10.0);
@property (strong, nonatomic, nullable) UNUserNotificationCenter *center  NS_AVAILABLE_IOS(10.0);
@property (copy, nonatomic, nullable)   NNNotificationCompletionHandler completionHandler  NS_AVAILABLE_IOS(10.0);
@property (copy, nonatomic, nullable)   NNNotificationPresentationOptionsHandler presentationOptionsHandler  NS_AVAILABLE_IOS(10.0);
#endif

@end


@interface NNOpenURLItem : NSObject

@property (strong, nonatomic) NSURL *URL;
@property (copy, nonatomic)   NSString *sourceApplication;
@property (strong, nonatomic) id annotation;
@property (copy, nonatomic)   NSDictionary<UIApplicationOpenURLOptionsKey,id> *options;

@end

/// ========================================
/// @name   3D Touch
/// ========================================

typedef void(^NNShortcutItemCompletionHandler)(BOOL succeeded);
@interface NNShortcutItem : NSObject
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
@property (strong, nonatomic) UIApplicationShortcutItem *shortcutItem __IOS_AVAILABLE(9.0);
@property (copy, nonatomic)   NNShortcutItemCompletionHandler completionHandler;
#endif
@end

/// ========================================
/// @name   UserActivity
/// ========================================

typedef void(^NNUserActivityRestorationHandler)(NSArray *);
@interface NNUserActivityItem : NSObject
@property (copy, nonatomic)   NSString *activityType;
@property (strong, nonatomic) NSUserActivity *userActivity;
@property (strong, nonatomic) NSError *error;
@property (copy, nonatomic)   NNUserActivityRestorationHandler restorationHandler;
@end

/// ========================================
/// @name   iWatch
/// ========================================

typedef void(^NNWatchReplyHandler)(NSDictionary *info);

@interface NNWatchItem : NSObject
@property (copy, nonatomic)   NSDictionary *userInfo;
@property (copy, nonatomic)   NNWatchReplyHandler replyHandler;
@end

NS_ASSUME_NONNULL_END

