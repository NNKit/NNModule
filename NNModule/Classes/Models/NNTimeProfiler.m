//  NNTimeProfiler.m
//  Pods
//
//  Created by  XMFraker on 2017/12/20
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNTimeProfiler
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNTimeProfiler.h"

@interface NNTimeProfiler ()

@property (strong, nonatomic) NSMutableArray<NSString *> *identifiers;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *records;

@property (assign, nonatomic) CFTimeInterval lastTime;
@property (assign, nonatomic) CFTimeInterval startTime;

@end

@implementation NNTimeProfiler

#pragma mark - Life Cycle

- (instancetype)init {
    
    if (self = [super init]) {
        
        _lastTime = CACurrentMediaTime();
        _startTime = CACurrentMediaTime();
        _identifiers = [NSMutableArray array];
        _records = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)sharedProfiler {
    static dispatch_once_t onceToken;
    static NNTimeProfiler *profiler = nil;
    dispatch_once(&onceToken, ^{
        profiler = [[NNTimeProfiler alloc] init];
    });
    return profiler;
}

#pragma mark - Public

- (void)recordEventTime:(NSString *)eventName {
    
#if DEBUG
    if (!eventName || !eventName.length) return;
    [self.identifiers addObject:eventName];
    [self.records setObject:@(CACurrentMediaTime()) forKey:eventName];
#endif
}

- (void)printTimeRecords {
    
#if DEBUG
    for (NSString *identifier in self.identifiers) {
        
        CFTimeInterval recordTime = [[self.records objectForKey:identifier] doubleValue];
        printf("[%s] time stamp: %gms and execute cost %gms -> \n",
               [identifier UTF8String],
               (recordTime - self.startTime) * 1000,
               (recordTime - self.lastTime) * 1000);
        self.lastTime = recordTime;
    }
#endif
}

- (void)saveRecordsToFile:(NSString *)fileName {
 
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath =  [documentPath stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"txt"]];
    
    BOOL res=[[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    if (!res) return;
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    for (NSString *eventName in self.identifiers) {
        CFTimeInterval current = [[self.records objectForKey:eventName] doubleValue];
        NSString *output = [NSString stringWithFormat:@"[%s] time stamp: %gms and execute cost %gms -> \n",
                            [eventName UTF8String],
                            (current - self.startTime) * 1000,
                            (current - self.lastTime) * 1000];
        [handle writeData:[output dataUsingEncoding:NSUTF8StringEncoding]];
        self.lastTime = current;
    }
    
    [handle closeFile];
}


@end
