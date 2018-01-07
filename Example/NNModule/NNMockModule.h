//  NNMockModule.h
//  NNModule
//
//  Created by  XMFraker on 2017/12/28
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNMockModule
//  @version    <#class version#>
//  @abstract   <#class description#>

#import <Foundation/Foundation.h>
#import <NNModule/NNModule.h>

@interface NNMockModule : NSObject <NNModuleProtocol>

@end

@interface NNMockErrorModule : NSObject
@end

@protocol NNMockService <NNServiceProtocol>

- (void)printSericeInstance;
- (id)serviceInstanceResponse;
- (int)serviceInstanceCode;
@end

@interface NNMockServiceModel : NSObject <NNMockService>
@end

@interface NNMockServiceErrorModel : NSObject
@end
