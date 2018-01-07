//  NNAppDelegate.m
//  Pods
//
//  Created by  XMFraker on 2017/12/20
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNAppDelegate
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNModulizedDelegate.h"
#import "NNContext.h"
#import "NNModuleProtocol.h"
#import "NNModuleManager.h"
#import "NNTimeProfiler.h"
#import "UIApplication+NNModulized.h"

@implementation NNModulizedDelegate
@synthesize window = _window;
#pragma mark - UIApplicationDelegate

/// ========================================
/// @name   Life Cycle
/// ========================================

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UIApplication sharedApplication].context.launchOptions = launchOptions;
    
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventSetup];
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventInit];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NNModuleManager sharedManager] triggerEvent:NNModuleEventSplash];
    });
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if (@available(iOS 10.0, *)) [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>)self;
#endif
    
    [[NNTimeProfiler sharedProfiler] printTimeRecords];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventWillTerminate];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventDidBecomeActive];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventWillResignActive];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventWillEnterForgeground];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventDidEnterBackground];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventReceiveMemoryWarning];
}

/// ========================================
/// @name   Notification
/// ========================================

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [UIApplication sharedApplication].context.notificationItem.error = error;
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventFailToRegisterForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [UIApplication sharedApplication].context.notificationItem.deviceToken = deviceToken;
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventRegisterRemoteNotification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [UIApplication sharedApplication].context.notificationItem.userInfo = userInfo;
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventReceiveRemoteNotification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    [UIApplication sharedApplication].context.notificationItem.userInfo = userInfo;
    [UIApplication sharedApplication].context.notificationItem.resultHandler = completionHandler;
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventReceiveLocalNotification];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    [UIApplication sharedApplication].context.notificationItem.localNotification = notification;
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventReceiveLocalNotification];
}

/// ========================================
/// @name   3D Touch
/// ========================================

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler NS_AVAILABLE_IOS(9_0) {
    
    [UIApplication sharedApplication].context.shortcutItem.shortcutItem = shortcutItem;
    [UIApplication sharedApplication].context.shortcutItem.completionHandler = completionHandler;
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventQuickAction];
}

#endif

/// ========================================
/// @name   Open URL
/// ========================================

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options NS_AVAILABLE_IOS(9_0) {
    
    [UIApplication sharedApplication].context.URLItem.URL = url;
    [UIApplication sharedApplication].context.URLItem.options = options;
    [UIApplication sharedApplication].context.URLItem.annotation = [options objectForKey:UIApplicationOpenURLOptionsAnnotationKey];
    [UIApplication sharedApplication].context.URLItem.sourceApplication = [options objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey];
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventOpenURL];
    return YES;
}

#endif

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url NS_DEPRECATED_IOS(2_0, 9_0, "Please use application:openURL:options:") {
 
    [UIApplication sharedApplication].context.URLItem.URL = url;
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventOpenURL];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation NS_DEPRECATED_IOS(2_0, 9_0, "Please use application:openURL:options:") {
    
    [UIApplication sharedApplication].context.URLItem.URL = url;
    [UIApplication sharedApplication].context.URLItem.sourceApplication = sourceApplication;
    [UIApplication sharedApplication].context.URLItem.annotation = annotation;
    [[NNModuleManager sharedManager] triggerEvent:NNModuleEventOpenURL];
    return YES;
}

/// ========================================
/// @name   User Activity
/// ========================================

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0

- (void)application:(UIApplication *)application
    didUpdateUserActivity:(NSUserActivity *)userActivity NS_AVAILABLE_IOS(8_0) {
    
    if (@available(iOS 8.0, *)) {
        [UIApplication sharedApplication].context.userActivityItem.userActivity = userActivity;
        [[NNModuleManager sharedManager] triggerEvent:NNModuleEventUpdateUserActivity];
    }
}

- (void)application:(UIApplication *)application
    didFailToContinueUserActivityWithType:(NSString *)userActivityType
                                    error:(NSError *)error NS_AVAILABLE_IOS(8_0) {
    
    if (@available(iOS 8.0, *)) {
        [UIApplication sharedApplication].context.userActivityItem.activityType = userActivityType;
        [UIApplication sharedApplication].context.userActivityItem.error = error;
        [[NNModuleManager sharedManager] triggerEvent:NNModuleEventFailedToContinueUserActivity];
    }
}

- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler NS_AVAILABLE_IOS(8_0) {
    
    if (@available(iOS 8.0, *)) {
        [UIApplication sharedApplication].context.userActivityItem.userActivity = userActivity;
        [UIApplication sharedApplication].context.userActivityItem.restorationHandler = restorationHandler;
        [[NNModuleManager sharedManager] triggerEvent:NNModuleEventContinueUserActivity];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application
    willContinueUserActivityWithType:(NSString *)userActivityType NS_AVAILABLE_IOS(8_0) {

    if (@available(iOS 8.0, *)) {
        [UIApplication sharedApplication].context.userActivityItem.activityType = userActivityType;
        [[NNModuleManager sharedManager] triggerEvent:NNModuleEventWillContinueUserActivity];
    }
    return YES;
}

#endif

/// ========================================
/// @name   iWatch
/// ========================================

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_2

- (void)application:(UIApplication *)application
    handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo
                             reply:(void(^)(NSDictionary * __nullable replyInfo))reply NS_AVAILABLE_IOS(8_2) {
    
    if (@available(iOS 8.2, *)) {
        [UIApplication sharedApplication].context.watchItem.userInfo = userInfo;
        [UIApplication sharedApplication].context.watchItem.replyHandler  = reply;
        [[NNModuleManager sharedManager] triggerEvent:NNModuleEventHandleWatchKitExtensionRequest];
    }
}

#endif

#pragma mark - UNUserNotificationCenterDelegate

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler NS_AVAILABLE_IOS(10.0) {
    
    if (@available(iOS 10.0, *)) {
        [UIApplication sharedApplication].context.notificationItem.center = center;
        [UIApplication sharedApplication].context.notificationItem.notification = notification;
        [UIApplication sharedApplication].context.notificationItem.presentationOptionsHandler = completionHandler;
        [[NNModuleManager sharedManager] triggerEvent:NNModuleEventWillPresentNotification];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler NS_AVAILABLE_IOS(10.0) {

    if (@available(iOS 10.0, *)) {
        [UIApplication sharedApplication].context.notificationItem.center = center;
        [UIApplication sharedApplication].context.notificationItem.notificationResponse = response;
        [UIApplication sharedApplication].context.notificationItem.completionHandler = completionHandler;
        [[NNModuleManager sharedManager] triggerEvent:NNModuleEventReceiveNotificationResponse];
    }
}

#endif

@end

@implementation NNNotificationItem
@end

@implementation NNOpenURLItem
@end

@implementation NNShortcutItem
@end

@implementation NNUserActivityItem
@end

@implementation NNWatchItem
@end
