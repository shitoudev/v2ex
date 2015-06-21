//
//  AppDelegate.swift
//  v2ex
//
//  Created by zhenwen on 5/2/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

public let _dismissAfter = 1.65

public let v2exUserLoginSuccessNotification = "shitou.v2exUserLoginSuccessNotification"
public let v2exUserLogoutSuccessNotification = "shitou.v2exUserLogoutSuccessNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        var navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = UIColor.colorWithHexString("#333344") //colorWithHexString("#333344")
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        UITabBar.appearance().tintColor = UIColor.colorWithHexString("#333344")
        
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        if MemberModel.sharedMember.isLogin() {
            println("登录中")
        } else {
            println("未登录")
        }
//        MemberModel.sharedMember.removeUserData()
        
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

