//  UIApplication+NNModulized.h
//  Pods
//
//  Created by  XMFraker on 2017/12/22
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      UIApplication_NNModulized
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NNContext;
@interface UIApplication (NNModulized)

/** 全局运行环境 */
@property (strong, nonatomic, readonly) NNContext *context;

@end

NS_ASSUME_NONNULL_END
