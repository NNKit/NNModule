//  NNTimeProfiler.h
//  Pods
//
//  Created by  XMFraker on 2017/12/20
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNTimeProfiler
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NNTimeProfiler : NSObject

/** NNTimeProfiler 单例 */
+ (instancetype)sharedProfiler;

/**
 控制台输入已统计记录
 @warnings 仅在DEBUG模式下有效
 */
- (void)printTimeRecords;

/**
 记录事件
 
 @warnings 仅在DEBUG模式下有效
 @param eventName 事件名称
 */
- (void)recordEventTime:(NSString *)eventName;

/**
 保存已统计的事件

 保存路径 ~/documents/{fileName}.txt
 @param fileName 文件名
 */
- (void)saveRecordsToFile:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
