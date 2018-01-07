//
//  NNModulizedDelegateSpec.swift
//  NNModule
//
//  Created by XMFraker on 2017/12/27.
//Copyright © 2017年 ws00801526. All rights reserved.
//

import Quick
import Nimble
@testable import NNModule

@objc class NNMockDelegateModule : NSObject, NNModuleProtocol {
    
    public var count:Int = 0
    public var method:String = ""
    public var context: NNContext?
    
    func handleCallBack(_ context: NNContext!, _ method: String!) {
        count += 1
        self.method = method
        self.context = context
    }
    
    func modQuickAction(_ context: NNContext!) {
        context.shortcutItem.completionHandler(true)
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modWillResignActive(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modDidEnterBackground(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modWillEnterForeground(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modDidBecomeActive(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modWillTerminate(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modTearDown(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modOpenURL(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modDidReceiveMemoryWaring(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modDidFailedRegisterRemoteNotification(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modDidReceiveRemoteNotification(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modDidRegisterRemoteNotifications(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modDidReceiveLocalNotification(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    //    func modWillPresentNotification(_ context: NNContext!) {
    //        handleCallBack(context, NSStringFromSelector(#function))
    //        if #available(iOS 10.0, *) {
    //            context.notificationItem.presentationOptionsHandler!(UNNotificationPresentationOptions.alert)
    //        } else {
    //            // Fallback on earlier versions
    //        }
    //    }
    //
    //    func modDidReceiveNotificationResponse(_ context: NNContext!) {
    //        handleCallBack(context, NSStringFromSelector(#function))
    //    }
    
    func modWillContinueUserActivity(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modContinueUserActivity(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
        context.userActivityItem.restorationHandler([1,2,3])
    }
    
    func modDidFailContinueUserActivity(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modDidUpdateUserActivity(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
    }
    
    func modHandleWatchKitExtensionRequest(_ context: NNContext!) {
        handleCallBack(context, NSStringFromSelector(#function))
        context.watchItem?.replyHandler([2 : "2"])
    }
}

class NNModulizedDelegateSpec: QuickSpec {
    override func spec() {
        describe("NNModulizedDelegate") {
            
            var module: NNMockDelegateModule?
            
            beforeEach {
                
                NNModuleManager.shared().registerDynamicModule(NNMockDelegateModule.self)
                let modules: NSArray = NNModuleManager.shared().value(forKey: "modules") as! NSArray
                module = (modules.firstObject as? NNMockDelegateModule)
            }
            
            afterEach {
                expect(module?.count).to(equal(1))
                expect(module?.context).notTo(beNil())
                NNModuleManager.shared().unregisterDyncmicModule(NNMockDelegateModule.self)
            }
            
            it("application will terminate", closure: {
                
                UIApplication.shared.delegate?.applicationWillTerminate?(UIApplication.shared)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modWillTerminate(_:)))
                expect(method).to(contain(module!.method))
                expect(module!.context!.customEvent).to(equal(NNModuleEvent.willTerminate.rawValue))
            })
            
            it("application resign active", closure: {
                UIApplication.shared.delegate?.applicationWillResignActive?(UIApplication.shared)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modWillResignActive(_:)))
                expect(method).to(contain(module!.method))
                expect(module!.context!.customEvent).to(equal(NNModuleEvent.willResignActive.rawValue))
            })
            
            it("application did become acive", closure: {
                UIApplication.shared.delegate?.applicationDidBecomeActive?(UIApplication.shared)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modDidBecomeActive(_:)))
                expect(method).to(contain(module!.method))
                expect(module!.context!.customEvent).to(equal(NNModuleEvent.didBecomeActive.rawValue))
            })
            
            it("application will enter foreground", closure: {
                UIApplication.shared.delegate?.applicationWillEnterForeground?(UIApplication.shared)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modWillEnterForeground(_:)))
                expect(method).to(contain(module!.method))
                expect(module!.context!.customEvent).to(equal(NNModuleEvent.willEnterForgeground.rawValue))
            })
            
            it("application did enter background", closure: {
                UIApplication.shared.delegate?.applicationDidEnterBackground?(UIApplication.shared)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modDidEnterBackground(_:)))
                expect(method).to(contain(module!.method))
                expect(module!.context!.customEvent).to(equal(NNModuleEvent.didEnterBackground.rawValue))
            })
            
            it("application receive memory warning", closure: {
                UIApplication.shared.delegate?.applicationDidReceiveMemoryWarning?(UIApplication.shared)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modDidReceiveMemoryWaring(_:)))
                expect(method).to(contain(module!.method))
                expect(module!.context!.customEvent).to(equal(NNModuleEvent.receiveMemoryWarning.rawValue))
            })
            
            it("application open url", closure: {
                let url = URL(string: "https://www.baidu.com")!
                let result = UIApplication.shared.delegate?.application?(UIApplication.shared, open: url, options: [:])
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modOpenURL(_:)))
                expect(result).to(beTrue())
                expect(method).to(contain(module!.method))
                expect(module!.context!.customEvent).to(equal(NNModuleEvent.openURL.rawValue))
                expect(module!.context!.urlItem.url).to(equal(url))
            })
            
            it("3DTouch Quick Action", closure: {
                let shortItem = UIApplicationShortcutItem.init(type: "test", localizedTitle: "test")
                var callBack = false
                UIApplication.shared.delegate?.application?(UIApplication.shared, performActionFor: shortItem, completionHandler: { result in
                    callBack = result
                })
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modQuickAction))
                expect(callBack).toEventually(beTrue())
                expect(method).to(contain(module!.method))
                expect(module!.context!.customEvent).to(equal(NNModuleEvent.quickAction.rawValue))
            })
            
            it("failed register notification", closure: {
                
                UIApplication.shared.delegate?.application?(UIApplication.shared, didFailToRegisterForRemoteNotificationsWithError: NNMockError.FailedRegisterRemoteNotification)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modDidFailedRegisterRemoteNotification(_:)))
                expect(method).to(contain(module!.method))
                expect(module!.context!.notificationItem.error as? NNMockError).to(equal(NNMockError.FailedRegisterRemoteNotification))
            })
            
            it("register remote notification", closure: {
                let token = "token".data(using: String.Encoding.utf8)
                UIApplication.shared.delegate?.application?(UIApplication.shared, didRegisterForRemoteNotificationsWithDeviceToken: token!)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modDidRegisterRemoteNotifications(_:)))
                expect(method).to(contain(module!.method))
                expect(module?.context?.notificationItem.deviceToken!).to(equal(token))
            })
            
            it("receive local notification", closure: {
                let notification = UILocalNotification()
                notification.alertTitle = "local"
                UIApplication.shared.delegate?.application?(UIApplication.shared, didReceive: notification)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modDidReceiveLocalNotification(_:)))
                expect(method).to(contain(module!.method))
                expect(module?.context?.notificationItem.localNotification).to(equal(notification))
            })
            
            it("receive remote notification", closure: {
                
                let userInfo = ["alertTitle":"remote"]
                UIApplication.shared.delegate?.application?(UIApplication.shared, didReceiveRemoteNotification: userInfo)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modDidReceiveRemoteNotification(_:)))
                expect(method).to(contain(module!.method))
                expect(module?.context?.notificationItem.userInfo as? [String : String]).to(equal(userInfo))
            })
            
            it("will continue user activity", closure: {
                let _ = UIApplication.shared.delegate?.application?(UIApplication.shared, willContinueUserActivityWithType: "will fire user activity")
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modWillContinueUserActivity(_:)))
                expect(method).to(contain(module!.method))
                expect(module!.context?.userActivityItem.activityType).to(equal("will fire user activity"))
            })
            
            it("continue user activity", closure: {
                
                let activity = NSUserActivity(activityType: "continue")
                var result: [Int]?
                let _ = UIApplication.shared.delegate?.application?(UIApplication.shared, continue: activity, restorationHandler: { ret in
                    result = ret as? [Int]
                })
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modContinueUserActivity(_:)))
                expect(method).to(contain(module!.method))
                expect(module?.context?.userActivityItem.userActivity).to(equal(activity))
                expect(result).toEventually(equal([1,2,3]))
            })
            
            it("update user activity", closure: {
                let activity = NSUserActivity(activityType: "update")
                let _ = UIApplication.shared.delegate?.application?(UIApplication.shared, didUpdate: activity)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modDidUpdateUserActivity(_:)))
                expect(method).to(contain(module!.method))
                expect(module?.context?.userActivityItem.userActivity).to(equal(activity))
            })
            
            it("failed continue user activity", closure: {
                
                let _ = UIApplication.shared.delegate?.application?(UIApplication.shared, didFailToContinueUserActivityWithType: "failed", error: NNMockError.FailedContinueUserActivity)
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modDidFailContinueUserActivity(_:)))
                expect(method).to(contain(module!.method))
                expect(module?.context?.userActivityItem.activityType).to(equal("failed"))
                expect(module?.context?.userActivityItem.error as? NNMockError).to(equal(NNMockError.FailedContinueUserActivity))
            })
            
            it("iWatch Event", closure: {
                
                let userInfo = [1 : "1"]
                var resultInfo: [Int:String]?
                UIApplication.shared.delegate?.application?(UIApplication.shared, handleWatchKitExtensionRequest: userInfo, reply: { ret in
                    resultInfo = ret as? [Int:String]
                })
                let method = NSStringFromSelector(#selector(NNMockDelegateModule.modHandleWatchKitExtensionRequest(_:)))
                expect(method).to(contain(module!.method))
                expect(module?.context?.watchItem.userInfo as? [Int:String]).to(equal(userInfo))
                expect(resultInfo).toEventually(equal([2 : "2"]))
            })
        }
    }
}
