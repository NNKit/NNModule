//  NNModule.h
//  Pods
//
//  Created by  XMFraker on 2017/12/22
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NNModule
//  @version    <#class version#>
//  @abstract   <#class description#>

#ifndef NNModule_h
#define NNModule_h

#if __has_include(<NNModule/NNModule.h>)
    #import <NNModule/NNRouter.h>
    #import <NNModule/NNContext.h>
    #import <NNModule/NNModuleManager.h>
    #import <NNModule/NNModuleProtocol.h>
    #import <NNModule/NNServiceManager.h>
    #import <NNModule/NNModulizedDelegate.h>

    #import <NNModule/UIApplication+NNModulized.h>
#else
    #import "NNRouter.h"
    #import "NNContext.h"
    #import "NNModuleManager.h"
    #import "NNModuleProtocol.h"
    #import "NNServiceManager.h"
    #import "NNModulizedDelegate.h"

    #import "UIApplication+NNModulized.h"
#endif

#endif /* NNModule_h */
