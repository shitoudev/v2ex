//
//  NotificationManage.swift
//  v2ex
//
//  Created by zhenwen on 8/20/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import v2exKit
import Kanna

public class NotificationManage: NSObject {

    var notificationTimer: NSTimer!
    var hasNewNotification: Bool {
        return unreadCount > 0
    }
    var unreadCount = 0 {
        didSet {
            let tabBarViewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! UITabBarController
            let viewController = tabBarViewController.viewControllers?.last as! UINavigationController
            viewController.tabBarItem.badgeValue = hasNewNotification ? "\(unreadCount)" : nil
            if let profileViewController = viewController.viewControllers.first as? ProfileViewController where profileViewController.isViewLoaded() {
                profileViewController.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 1)], withRowAnimation: .Automatic)
            }
            UIApplication.sharedApplication().applicationIconBadgeNumber = unreadCount
        }
    }
    
    override init() {
        super.init()
        
        self.notificationTimer = NSTimer(timeInterval: 60, target: self, selector: Selector("timerHandler:"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(notificationTimer, forMode: NSRunLoopCommonModes)
    }
    
    internal static let sharedManager: NotificationManage = {
        return NotificationManage()
    }()
    
    // MARK: Timer
    func timerHandler(sender: NSTimer) {
        if !MemberModel.sharedMember.isLogin() {
            return
        }
//        println("timerHandler")
        let url = APIManage.baseURLString
        APIManage.sharedManager.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (req, resp, str) -> Void in
            if str.isSuccess {
                guard let doc = HTML(html: str.value!, encoding: NSUTF8StringEncoding) else {
                    return
                }
                if let notificationNode = doc.at_css("a[href='/notifications']"), docText = notificationNode.text {
                    let components = docText.componentsSeparatedByString(" ")
                    if components.first != nil {
                        let unreadNum = (components.first! as NSString).integerValue //.toInt()
                        self.unreadCount = unreadNum
                    }
                }
            }
        })
    }
    
    func timerStop() {
        notificationTimer.fireDate = NSDate.distantFuture()
    }
    
    func timerRestart() {
        print(notificationTimer)
        notificationTimer.fireDate = NSDate.distantPast()
    }
}