//
//  NNAppDelegate.m
//  NNModule
//
//  Created by ws00801526 on 12/22/2017.
//  Copyright (c) 2017 ws00801526. All rights reserved.
//

#import "NNTestDelegate.h"

@implementation NNTestDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    UIViewController *rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NNViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
