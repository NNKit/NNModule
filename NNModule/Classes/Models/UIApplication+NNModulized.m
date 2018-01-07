//  UIApplication+NNModulized.m
//  Pods
//
//  Created by  XMFraker on 2017/12/22
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      UIApplication_NNModulized
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "UIApplication+NNModulized.h"
#import "NNContext.h"

#import <objc/runtime.h>

@implementation UIApplication (NNModulized)

#pragma mark - Getter

- (NNContext *)context {
    
    NNContext *context = objc_getAssociatedObject(self, _cmd);
    if (!context) {
        context = [[NNContext alloc] init];
        objc_setAssociatedObject(self, _cmd, context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return context;
}

@end
