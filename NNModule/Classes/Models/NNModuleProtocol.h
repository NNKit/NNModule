//  NNModuleProtocol.h
//  Pods
//
//  Created by  XMFraker on 2017/12/21
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNModuleProtocol
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <Foundation/Foundation.h>

@class NNContext;

typedef NS_ENUM(NSUInteger, NNModuleEvent) {
    NNModuleEventSetup = 0,
    NNModuleEventInit,
    NNModuleEventTearDown,
    NNModuleEventSplash,
    NNModuleEventQuickAction,
    NNModuleEventWillResignActive,
    NNModuleEventDidEnterBackground,
    NNModuleEventWillEnterForgeground,
    NNModuleEventDidBecomeActive,
    NNModuleEventWillTerminate,
    NNModuleEventUnmount,
    NNModuleEventOpenURL,
    NNModuleEventReceiveMemoryWarning,
    NNModuleEventFailToRegisterForRemoteNotifications,
    NNModuleEventRegisterRemoteNotification,
    NNModuleEventReceiveRemoteNotification,
    NNModuleEventReceiveLocalNotification,
    NNModuleEventWillPresentNotification,
    NNModuleEventReceiveNotificationResponse,
    NNModuleEventWillContinueUserActivity,
    NNModuleEventContinueUserActivity,
    NNModuleEventFailedToContinueUserActivity,
    NNModuleEventUpdateUserActivity,
    NNModuleEventHandleWatchKitExtensionRequest,
    NNModuleEventCustom = 1000
};

@protocol NNModuleProtocol <NSObject>

@optional
/** 是否异步调用modInit: */
- (BOOL)isAsync;
/** 模块优先级, 数值越大, 越优先 */
- (NSUInteger)priority;

/** called in @code - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions @endcode */
- (void)modSetUp:(NNContext *)context;

/** called in @code - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions @endcode */
- (void)modInit:(NNContext *)context;

/** called in @code - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions @endcode */
- (void)modSplash:(NNContext *)context;

/** called in @code - (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler @endcode */
- (void)modQuickAction:(NNContext *)context;

/** called in @code - (void)applicationWillResignActive:(UIApplication *)application @endcode */
- (void)modWillResignActive:(NNContext *)context;

/** called in @code - (void)applicationDidEnterBackground:(UIApplication *)application @endcode */
- (void)modDidEnterBackground:(NNContext *)context;

/** called in @code - (void)applicationWillEnterForeground:(UIApplication *)application @endcode */
- (void)modWillEnterForeground:(NNContext *)context;

/** called in @code - (void)applicationDidBecomeActive:(UIApplication *)application @endcode */
- (void)modDidBecomeActive:(NNContext *)context;

/** called in @code - (void)applicationWillTerminate:(UIApplication *)application @endcode */
- (void)modWillTerminate:(NNContext *)context;

/** called when module unregister  */
- (void)modTearDown:(NNContext *)context;

/** called in @code - (void)applicationWillTerminate:(UIApplication *)application @endcode */
- (void)modOpenURL:(NNContext *)context;

/** called in @code - (void)applicationWillTerminate:(UIApplication *)application @endcode */
- (void)modDidReceiveMemoryWaring:(NNContext *)context;

/** called in @code - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error @endcode */
- (void)modDidFailedRegisterRemoteNotification:(NNContext *)context;

/** called in @code - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken @endcode */
- (void)modDidRegisterRemoteNotifications:(NNContext *)context;

/** called in @code - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler @endcode */
- (void)modDidReceiveRemoteNotification:(NNContext *)context;

/** called in @code - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification @endcode */
- (void)modDidReceiveLocalNotification:(NNContext *)context;

/** called in @code - (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler @endcode */
- (void)modWillPresentNotification:(NNContext *)context;

/** called in @code - (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler @endcode */
- (void)modDidReceiveNotificationResponse:(NNContext *)context;

/** called in @code - (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType @endcode */
- (void)modWillContinueUserActivity:(NNContext *)context;

/** called in @code - (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler @endcode */
- (void)modContinueUserActivity:(NNContext *)context;

/** called in @code - (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error @endcode */
- (void)modDidFailContinueUserActivity:(NNContext *)context;

/** called in @code - (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity @endcode */
- (void)modDidUpdateUserActivity:(NNContext *)context;

/** called in @code - (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply @endcode */
- (void)modHandleWatchKitExtensionRequest:(NNContext *)context;

/** called when trigger customEvent(> 1000) */
- (void)modDidCustomEvent:(NNContext *)context;

@end
