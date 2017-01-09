//
//  AppDelegate.swift
//  hrtwiliocall
//
//  Created by Elizabeth Siegle on 1/2/17.
//  Copyright © 2017 Elizabeth Siegle. All rights reserved.
//

import UIKit
import WatchConnectivity
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    let healthStore = HKHealthStore()
    
    var someData = [String]()
    
    override init() {
        super.init()
    }
    
    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if WCSession.isSupported() {
            session = WCSession.default()
            session!.delegate = self
            session?.activate()
        }
        else {
            print("wcSession not supported")
        }
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    // authorization from watch
    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        
        self.healthStore.handleAuthorizationForExtension(completion: { success, error in
            
        })
    }
}

extension AppDelegate: WCSessionDelegate {
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("inactive")
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        print("flipping deactivate")
    }
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("eff dis")
    }
    
    
    private func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        if let hrVal = message["heart rate value"] as? String {
            self.someData.append(hrVal)
        }
    }
    
}

