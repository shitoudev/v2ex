//
//  AppDelegate.swift
//  v2ex
//
//  Created by zhenwen on 5/2/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import v2exKit
import Fabric
import Crashlytics

public let _dismissAfter = 1.65

public let v2exUserLoginSuccessNotification = "shitou.v2exUserLoginSuccessNotification"
public let v2exUserLogoutSuccessNotification = "shitou.v2exUserLogoutSuccessNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /// 需要跳转的VC
    var openURLQueue: [UIViewController] = []
    /// 应用是否处于活动中
    var appActiveing = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = kAppNormalColor
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        UITabBar.appearance().tintColor = kAppNormalColor
        
        application.statusBarStyle = UIStatusBarStyle.LightContent
        window?.tintColor = kAppNormalColor
        
        NotificationManage.sharedManager

        if MemberModel.sharedMember.isLogin() {
            print("登录中")
        } else {
            print("未登录")
            NotificationManage.sharedManager.timerStop()
        }
//        MemberModel.sharedMember.removeUserData()
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Badge, .Alert, .Sound], categories: nil))
        
        Fabric.with([Crashlytics.self])
        Flurry.startSession("4PJF88FR8SBPJBV3R69V")
        
        // Override point for customization after application launch.
        return true
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        if MemberModel.sharedMember.isLogin() {
            NotificationManage.sharedManager.timerStop()
        }
        appActiveing = false
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        pushToViewController()
        
        if MemberModel.sharedMember.isLogin() {
            NotificationManage.sharedManager.timerRestart()
        }
        appActiveing = true
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return handlerURL(url)
    }
    
    func application(application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return userActivityType == "com.apple.corespotlightitem"
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        print("continueUserActivity")
        let identifier = userActivity.userInfo?["kCSSearchableItemActivityIdentifier"] as! String
        let url = NSURL(string: identifier)!
        return handlerURL(url)
    }
    
    func handlerURL(url: NSURL) -> Bool {
        print("url = \(url)")
        let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)!
        guard let host = urlComponents.host, queryItems = urlComponents.queryItems where host == "post" else {
            return false
        }
        var postId = 0
        for item in queryItems {
            if let val = item.value where item.name == "postId" {
                postId = (val as NSString).integerValue
                break
            }
        }
        guard postId > 0 else {
            return false
        }
        openURLQueue.removeAll(keepCapacity: true)
        let viewController = PostDetailViewController().allocWithRouterParams(nil)
        viewController.postId = postId
        openURLQueue.append(viewController)
        if appActiveing {
            pushToViewController()
        }
        return true
    }
    
    func pushToViewController() {
        guard openURLQueue.count > 0 else {
            return
        }
        let application = UIApplication.sharedApplication()
        let viewController = openURLQueue.first!
        let tabbarController = application.keyWindow?.rootViewController as! UITabBarController
        if let selectedViewController = tabbarController.selectedViewController as? UINavigationController {
            selectedViewController.pushViewController(viewController, animated: true)
            openURLQueue.removeAll(keepCapacity: true)
        }
    }
}

