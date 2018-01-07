//
//  NNModuleSpec.swift
//  NNModule
//
//  Created by XMFraker on 2017/12/26.
//Copyright © 2017年 ws00801526. All rights reserved.
//

import Quick
import Nimble
@testable import NNModule

@objc protocol NNMockProtocol : NNServiceProtocol {
    
    func printHello() -> String
}

@objc protocol NNMockSingleProtocol : NNMockProtocol {
    
    func printHello() -> String
}

@objc class NNMockService : NSObject, NNMockProtocol {
    
    func printHello() -> String {
        return "i am mock service"
    }
}

enum NNMockError : Error {
    case FailedRegisterRemoteNotification
    case FailedContinueUserActivity
}

@objc class NNMockSingleService: NSObject, NNMockSingleProtocol {
    
    static let shared = NNMockSingleService()
    override private init() {}
    
    static func isSingleton() -> Bool {
        return true
    }
    
    static func sharedInstance() -> Any {
        return shared
    }
    
    func printHello() -> String {
        return "i am single mock service"
    }
}

@objc class NNMockModule : NSObject, NNModuleProtocol {
    
    public var count:Int = 0
    func modSetUp(_ context: NNContext!) {
        count += 1
    }

    func modInit(_ context: NNContext!) {
        count += 1
    }
    
    func modSplash(_ context: NNContext!) {
        count += 1
    }
    
    func modQuickAction(_ context: NNContext!) {
        count += 1
    }
    
    @objc func modReceiveCustomEvent(_ context: NNContext!) {
        count += Int(context.customEvent)
        print("receive custom event \(context.customEvent)")
    }
}

@objc class NNMockAsyncModule : NSObject, NNModuleProtocol {
    public var count:Int = 0
    
    func isAsync() -> Bool {
        return true
    }
    
    func modSetUp(_ context: NNContext!) {
        count += 1
    }
    
    func modInit(_ context: NNContext!) {
        count += 1
    }
}

class NNModuleSpec: QuickSpec {
    
    override func spec() {
        
        describe("NNServiceManager") {
          
            beforeEach {
                expect(NNServiceManager.shared()).notTo(beNil())
            }

            it("register impClass of correct protocol", closure: {
                NNServiceManager.shared().registerService(NNMockProtocol.self, implClass: NNMockService.self)
                let instance:NNMockProtocol = NNServiceManager.shared().createServiceInstance(NNMockProtocol.self) as! NNMockProtocol
                expect(instance).notTo(beNil())
                
                let word = instance.printHello()
                expect(word).to(equal("i am mock service"))
            })
            
            it("register class not implement correct protocol", closure: {
                NNServiceManager.shared().registerService(NNMockSingleProtocol.self, implClass: NNMockService.self)
                let instance = NNServiceManager.shared().createServiceInstance(NNMockSingleProtocol.self)
                expect(instance).to(beNil())
            })
            
            it("register single class", closure: {
                NNServiceManager.shared().registerService(NNMockSingleProtocol.self, implClass: NNMockSingleService.self);
                let instance:NNMockSingleProtocol = NNServiceManager.shared().createServiceInstance(NNMockSingleProtocol.self) as! NNMockSingleProtocol
                expect(instance).notTo(beNil())
                let sharedInstance = NNMockSingleService.sharedInstance()
                expect(instance).notTo(beNil())
                expect(instance).to(be(sharedInstance))
                
                let word = instance.printHello()
                expect(word).to(equal("i am single mock service"))

            })
        }
        
        describe("NNTimeProfiler") {
            
            it("test log record", closure: {
                expect(NNTimeProfiler.shared()).notTo(beNil())
                NNTimeProfiler.shared().recordEventTime("TestEvent1")
                NNTimeProfiler.shared().recordEventTime("TestEvent2")
                NNTimeProfiler.shared().printTimeRecords()
                NNTimeProfiler.shared().saveRecords(toFile: "TimeProfiler")
                
                let fileDir:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                let filePath = "\(fileDir)/TimeProfiler.txt"
                expect(FileManager.default.fileExists(atPath: filePath)).to(beTrue())
            })
        }
        
        describe("NNModuleManager") {
         
            afterEach {
                NNModuleManager.shared().unregisterDyncmicModule(NNMockModule.self)
                NNModuleManager.shared().unregisterDyncmicModule(NNMockAsyncModule.self)
                let modules: NSArray = NNModuleManager.shared().value(forKey: "modules") as! NSArray
                expect(modules.count).to(equal(0))
            }
            
            it("register module and not trigger init", closure: {
                expect(NNModuleManager.shared()).notTo(beNil())
                NNModuleManager.shared().registerDynamicModule(NNMockModule.self)
                let modules: NSArray = NNModuleManager.shared().value(forKey: "modules") as! NSArray
                let module: NNMockModule = modules.firstObject as! NNMockModule
                expect(module.count).to(equal(0))
            })
            
            it("register module then trigger init", closure: {
              
                // will trigger modSetUp:, modInit:, modSplash:
                NNModuleManager.shared().registerDynamicModule(NNMockModule.self, shouldTriggetInitEvent: true)
                let modules: NSArray = NNModuleManager.shared().value(forKey: "modules") as! NSArray
                let module: NNMockModule = modules.firstObject as! NNMockModule
                expect(module.count).toEventually(equal(3))
            })
            
            it("register async module then trigger init", closure: {
                // will trigger modSetUp:, modInit:, modSplash:
                NNModuleManager.shared().registerDynamicModule(NNMockAsyncModule.self, shouldTriggetInitEvent: true)
                let modules: NSArray = NNModuleManager.shared().value(forKey: "modules") as! NSArray
                let module: NNMockAsyncModule = modules.firstObject as! NNMockAsyncModule
                expect(module.isAsync()).to(beTrue())
                expect(module.count).to(equal(1))
                expect(module.count).toEventually(equal(2))
            })
            
            it("register module then trigger event by code", closure: {
                
                NNModuleManager.shared().registerDynamicModule(NNMockModule.self, shouldTriggetInitEvent: false)
                let modules: NSArray = NNModuleManager.shared().value(forKey: "modules") as! NSArray
                let module: NNMockModule = modules.firstObject as! NNMockModule
                expect(module.count).to(equal(0))

                NNModuleManager.shared().triggerEvent(NNModuleEvent.splash.rawValue)
                expect(module.count).to(equal(1))
                NNModuleManager.shared().triggerEvent(NNModuleEvent.quickAction.rawValue)
                expect(module.count).to(equal(2))
                NNModuleManager.shared().triggerEvent(NNModuleEvent.continueUserActivity.rawValue)
                expect(module.count).to(equal(2))
            })
            
            it("register module then trigger custom event", closure: {
                
                NNModuleManager.shared().registerDynamicModule(NNMockModule.self, shouldTriggetInitEvent: false)
                let modules: NSArray = NNModuleManager.shared().value(forKey: "modules") as! NSArray
                let module: NNMockModule = modules.firstObject as! NNMockModule
                expect(module.count).to(equal(0))

                NNModuleManager.shared().registerCustomEvent(2000, moduleInstance: module, selector: #selector(NNMockModule.modReceiveCustomEvent(_:)))
                expect(module.count).to(equal(0))
                NNModuleManager.shared().triggerEvent(2000)
                expect(module.count).to(equal(2000))
            })
        }
    }
}
