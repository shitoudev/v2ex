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
//import Flurry

public let _dismissAfter = 1.65

public let v2exUserLoginSuccessNotification = "shitou.v2exUserLoginSuccessNotification"
public let v2exUserLogoutSuccessNotification = "shitou.v2exUserLogoutSuccessNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var openURLQueue: [UIViewController] = []

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        var navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = kAppNormalColor
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        UITabBar.appearance().tintColor = kAppNormalColor
        
        application.statusBarStyle = UIStatusBarStyle.LightContent
        window?.tintColor = kAppNormalColor
        
        if MemberModel.sharedMember.isLogin() {
            println("登录中")
        } else {
            println("未登录")
        }
//        MemberModel.sharedMember.removeUserData()
        
        Fabric.with([Crashlytics()])
        
        
        // Override point for customization after application launch.
        return true
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if openURLQueue.count > 0 {
            let viewController = openURLQueue.first!
            let tabbarController = application.keyWindow?.rootViewController as! UITabBarController
            if let selectedViewController = tabbarController.selectedViewController as? UINavigationController {
                selectedViewController.pushViewController(viewController, animated: true)
                openURLQueue.removeAll(keepCapacity: true)
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)!
        if urlComponents.host == "post" {
            if let queryItems = urlComponents.queryItems {
                var postId = 0
                for item in queryItems {
                    if (item as! NSURLQueryItem).name == "postId" {
                        if let val = (item as! NSURLQueryItem).value {
                            postId = val.toInt()!
                            break
                        }
                    }
                }
                if postId > 0 {
                    openURLQueue.removeAll(keepCapacity: true)
                    let viewController = PostDetailViewController().allocWithRouterParams(nil)
                    viewController.postId = postId
                    openURLQueue.append(viewController)
                }
                
            }
        }
        return true
    }


}

