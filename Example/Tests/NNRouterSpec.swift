//
//  NNRouterSpec.swift
//  NNModule
//
//  Created by XMFraker on 2017/12/27.
//Copyright © 2017年 ws00801526. All rights reserved.
//

import Quick
import Nimble
import NNModule

class NNRouterSpec: QuickSpec {
    override func spec() {
        describe("NNRouter instance") {
            
            it("create router", closure: {
                
                expect(NNRouter.global()).notTo(beNil())
                expect(NNRouter.global().scheme).to(equal("org.cocoapods.demo.NNModule-Example"))
                
                let customRouter = NNRouter(ofScheme: "icare")!
                expect(customRouter).notTo(beNil())
                expect(customRouter.scheme).to(equal("icare"))
                
                let customRouterAfter = NNRouter(ofScheme: "icare")!
                expect(customRouter).to(equal(customRouterAfter))
            })
            
            it("unreigster all router", closure: {
                
                let globalRouter = NNRouter.global()
                NNRouter.unregisterAllRouters()
                let globalRouterAfter = NNRouter.global()
                
                expect(globalRouter).notTo(beNil())
                expect(globalRouterAfter).notTo(beNil())
                expect(globalRouter).notTo(equal(globalRouterAfter))
            })
            
            it("unregister router using scheme", closure: {
                
                let customRouter = NNRouter(ofScheme: "icare")!
                expect(customRouter).notTo(beNil())
                NNRouter.unregisterRouter(ofScheme: "icare")
                
                let customRouterAfter = NNRouter(ofScheme: "icare")!
                expect(customRouterAfter).notTo(beNil())
                expect(customRouter).notTo(equal(customRouterAfter))
            })
        }
        
        describe("NNRouoter registerPathComponent") {
            
            beforeEach {
                let _ = NNRouter(ofScheme: "icare")
                let url = URL(string: "icare://register.service.router/icare.NNMockService.printServiceInstance")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beFalse())
            }
            
            afterEach {
                let url = URL(string: "icare://register.service.router/icare.NNMockService.printServiceInstance")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beTrue())
            }
            
            it("register path component", closure: {
                NNRouter(ofScheme: "icare")!.registerPathComponent("icare", implClass: NSClassFromString("NNMockModule")!)
            })
        }
        
        describe("NNRouter canOpenURL:") {
            
            beforeEach {
                let _ = NNRouter(ofScheme: "icare")
            }
            
            afterEach {
                NNRouter.unregisterAllRouters()
            }
            
            it("when router unexists", closure: {
                let url = URL(string: "call.service.selector.router/somekey.someprotocol.someselector")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beFalse())
            })
            
            it("no path component", closure: {
                let url = URL(string: "icare://call.service.selector.router")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beFalse())
            })
            
            it("unknown usage", closure: {

                let url = URL(string: "icare://call.service.selector.router.unknown.usage/somekey.someprotocol.someselector")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beFalse())
            })
            
            it("unknown class", closure: {
                let url = URL(string: "icare://call.service.selector.router/unknown_class.someprotocol.someselector")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beFalse())
            })
            
            it("correct call service url", closure: {
                let url = URL(string: "icare://call.service.selector.router/NNViewController.NNServiceProtocol.printHelloWorld")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beTrue())
            })
            
            it("correct enter view controller url", closure: {
                let url = URL(string: "icare://enter.viewcontroller.router/NNViewController.NNServiceProtocol.push")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beTrue())
            })
            
            it("correct reigister module url", closure: {
                let url = URL(string: "icare://register.module.router/NNMockModule")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beTrue())
            })
            
            it("register module url should be failed because NNMockErrorModule not conform NNModuleProtocol", closure: {
                let url = URL(string: "icare://register.module.router/NNMockErrorModule")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beFalse())
            })
            
            it("correct register service url", closure: {
                let url = URL(string: "icare://register.service.router/NNMockServiceModel.NNMockService.printServiceInstance")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beTrue())
            })
            
            it("register service url should be failed because NNMockServiceErrorModel not conform NNMockService", closure: {
                let url = URL(string: "icare://register.service.router/NNMockServiceErrorModel.NNMockService.printServiceInstance")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beFalse())
            })
            
            it("register service url should be failed because NNMockServiceErrorModel not conform NNMockService", closure: {
                let url = URL(string: "icare://register.service.router/NNMockServiceErrorModel.NNMockService.printServiceInstanceError")!
                let result = NNRouter.canOpen(url)
                expect(result).to(beFalse())
            })
        }
        
        describe("NNRouter openURL") {
         
            beforeSuite {
                let _ = NNRouter(ofScheme: "icare")
            }

            afterSuite {
                NNRouter.unregisterRouter(ofScheme: "icare")
            }
            
            beforeEach {
                let rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NNViewController")
                let nav = UINavigationController(rootViewController: rootViewController)
                UIApplication.shared.keyWindow?.rootViewController = nav
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            }
            
            it("call service selector", closure: {
                let url = URL(string: "icare://call.service.selector.router/NNMockServiceModel.NNMockService.printSericeInstance")!
                let success = NNRouter.open(url)
                expect(success).to(beTrue())
            })
            
            it("call service selector with URLParams", closure: {
                let url = URL(string: "icare://call.service.selector.router/NNMockServiceModel.NNMockService.printSericeInstance?params=%7b%22title%22%3a%22name%22%7d")!
                let success = NNRouter.open(url)
                expect(success).to(beTrue())
            })
            
            it("call service selector with completion handler", closure: {
                
                let url = URL(string: "icare://call.service.selector.router/NNMockServiceModel.NNMockService.serviceInstanceResponse")!
                var target: Any?
                var result: Any?
                let success = NNRouter.open(url, userInfo: nil, completionHandler: { (t, r) in
                    target = t
                    result = r
                })

                expect(success).to(beTrue())
                expect(target).notTo(beNil())
                expect(result).notTo(beNil())
                expect(result as? [String:Int]).toEventually(equal(["success":1]))
            })
            
            it("call service will custom handler", closure: {
                
                NNRouter(ofScheme: "icare")?.registerPathComponent("icare", implClass: NSClassFromString("NNMockServiceModel")!, customHandler: { (target, params) -> Any? in
                    print("handle service custom handler \(target!) with params \(params!)")
                    return ["success" : 1]
                })
                
                var target: Any?
                var result: Any?
                let url = URL(string: "icare://call.service.selector.router/icare")!
                let success = NNRouter.open(url, userInfo: ["icare":["name":"XMFraker"]], completionHandler: { (t, r) in
                    target = t
                    result = r
                })
                expect(success).to(beTrue())
                expect(target).notTo(beNil())
                expect(result).notTo(beNil())
                expect(result as? [String:Int]).toEventually(equal(["success":1]))
            })

            it("enter viewcontroller using push", closure: {
                let url = URL(string: "icare://enter.viewcontroller.router/NNViewController.NNServiceProtocol#push")
                let success = NNRouter.open(url!, userInfo: ["name":"XMFraker","title":"exists"])
                expect(success).to(beTrue())
                
                let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
                expect(nav?.viewControllers.count).toEventually(equal(2))
                expect(nav?.viewControllers.last?.title).toEventually(equal("exists"))
            })

            it("enter viewcontroller using modal", closure: {
                let url = URL(string: "icare://enter.viewcontroller.router/NNViewController.NNServiceProtocol.modal")
                let success = NNRouter.open(url!, userInfo: ["name":"XMFraker","title":"exists"])
                expect(success).to(beTrue())

                let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
                expect(nav?.viewControllers.count).toEventually(equal(1))
                expect(nav?.viewControllers.first?.presentedViewController).toNotEventually(beNil())
                expect(nav?.viewControllers.first?.presentedViewController?.title).toEventually(equal("exists"))
            })
        }
    }
}
