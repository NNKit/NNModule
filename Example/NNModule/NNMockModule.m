//  NNMockModule.m
//  NNModule
//
//  Created by  XMFraker on 2017/12/28
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNMockModule
//  @version    <#class version#>
//  @abstract   <#class description#>

#import "NNMockModule.h"

@implementation NNMockModule
@end

@implementation NNMockErrorModule
@end

@implementation NNMockServiceModel

- (void)printSericeInstance {
    NSLog(@"class :%@", NSStringFromClass([self class]));
}

- (id)serviceInstanceResponse {
    return @{@"success" : @1}.mutableCopy;
}

- (int)serviceInstanceCode {
    return 13;
}

@end

@implementation NNMockServiceErrorModel
@end
