//  NNServiceManager.m
//  Pods
//
//  Created by  XMFraker on 2017/12/21
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNServiceManager
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNServiceManager.h"

@interface NNServiceManager ()

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *serviceClassMapper;
@property (strong, nonatomic) dispatch_semaphore_t lock;

@end

@implementation NNServiceManager

#pragma mark - Life Cycle

+ (instancetype)sharedManager {
    
    static NNServiceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NNServiceManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        _serviceClassMapper = [NSMutableDictionary dictionary];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - Public

- (void)registerService:(Protocol *)protocol implClass:(Class)implClass {
    
    NSParameterAssert(protocol);
    NSParameterAssert(implClass);
    
    if (![implClass conformsToProtocol:protocol]) return;
    NSString *key = NSStringFromProtocol(protocol);
    NSString *value = NSStringFromClass(implClass);
    if (!key.length || !value.length) return;

    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    if ([self.serviceClassMapper objectForKey:key]) return;
    [self.serviceClassMapper setObject:value forKey:key];
    dispatch_semaphore_signal(self.lock);
}

- (id)createServiceInstance:(Protocol *)protocol {

    if (!protocol) return nil;

    // get protocol implementation class
    NSString *key = NSStringFromProtocol(protocol);
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    NSString *value = [self.serviceClassMapper objectForKey:key];
    dispatch_semaphore_signal(self.lock);
    if (!value.length) return nil;
    Class implClass = NSClassFromString(value);
    if (![implClass conformsToProtocol:protocol]) return nil;
    
    // get implClass instance
    if ([implClass respondsToSelector:@selector(isSingleton)]
        && [implClass isSingleton]
        && [implClass respondsToSelector:@selector(sharedInstance)]) {
        return [implClass sharedInstance];
    }
    return [[implClass alloc] init];
}

@end
