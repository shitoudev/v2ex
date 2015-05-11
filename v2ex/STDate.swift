//
//  STDate.swift
//  v2ex
//
//  Created by zhenwen on 5/11/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation

extension String {
    
    static func smartDate (strtotime: NSTimeInterval) -> String {
        var smartStr = ""

        var currentDate = NSDate().timeIntervalSince1970
        var endDate = NSDate(timeIntervalSince1970: strtotime)

        var distanceTime = currentDate - strtotime
        var dateFormatter = NSDateFormatter()
        
//        println("currentDate = \(currentDate), strtotime \(strtotime), distanceTime = \(distanceTime)")
        
        if distanceTime < 60 {
            //20分钟以内
            smartStr = "刚刚"
        }else if distanceTime >= 1*60 && distanceTime < 60*60 {
            //20分钟~1小时
            smartStr = NSString(format: "%d分钟之前", Int(distanceTime/60)) as String
        }else if distanceTime >= 60*60 && distanceTime < 24*60*60 {
            //1~24小时
            smartStr = NSString(format: "%d小时之前", Int(distanceTime/(60*60))) as String
        }else if distanceTime >= 24*60*60 && distanceTime < 2*24*60*60 {
            //昨天
            dateFormatter.dateFormat = "HH:mm"
            smartStr = NSString(format: "昨天 %s", dateFormatter.stringFromDate(endDate)) as String
        }else if distanceTime >= 2*24*60*60 && distanceTime < 3*24*60*60 {
            //前天
            dateFormatter.dateFormat = "HH:mm"
            smartStr = NSString(format: "前天 %s", dateFormatter.stringFromDate(endDate)) as String
        }else if distanceTime >= 3*24*60*60 && distanceTime < 365*24*60*60 {
            //一年之内
            dateFormatter.dateFormat = "MM/dd HH:mm"
            smartStr = dateFormatter.stringFromDate(endDate) as String
        }else if distanceTime >= 365*24*60*60 {
            //一年之外
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            smartStr = dateFormatter.stringFromDate(endDate) as String
        }
        
        return smartStr
    }

}
