//  NNContext.m
//  Pods
//
//  Created by  XMFraker on 2017/12/20
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNContext
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNContext.h"
#import "NNModulizedDelegate.h"

@implementation NNContext

#pragma mark - Life Cycle

- (instancetype)init {
    
    if (self = [super init]) {
        
        _URLItem = [[NNOpenURLItem alloc] init];
        _watchItem = [[NNWatchItem alloc] init];
        _notificationItem = [[NNNotificationItem alloc] init];
        _userActivityItem = [[NNUserActivityItem alloc] init];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4
        _shortcutItem = [[NNShortcutItem alloc] init];
#endif
        _config = [[NSUserDefaults alloc] initWithSuiteName:@"com.xmfraker.NNModule.context.config"];
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    NNContext *context = [[self.class allocWithZone:zone] init];
    context.env = self.env;
    context.config = self.config;
    context.launchOptions = self.launchOptions;
    context.URLItem = self.URLItem;
    context.watchItem = self.watchItem;
    context.notificationItem = self.notificationItem;
    context.userActivityItem = self.userActivityItem;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4
    context.shortcutItem = self.shortcutItem;
#endif
    return context;
}

@end
