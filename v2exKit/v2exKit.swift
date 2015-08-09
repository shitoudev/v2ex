//
//  v2exKit.swift
//  v2ex
//
//  Created by zhenwen on 6/25/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

public let kAppGroupIdentifier = "group.cc.yueti.v2ex"
public let kAppSharedDefaultsTodayExtensionDataKey = "cc.yueti.today.extension"

public let kLinkColor = "#778087"
public let kAppNormalColor = UIColor.colorWithHexString("#333344")
public let kIsiPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
public let kContentFont = kIsiPad ? UIFont.systemFontOfSize(16) : UIFont.systemFontOfSize(14)
public let kTitleFont = kIsiPad ? UIFont.systemFontOfSize(16) : UIFont.systemFontOfSize(14)

/**
修改链接的文字属性

:param: attrStr 内容源
:param: range   修改的内容范围

:returns: 修改之后的内容
*/
public func addLinkAttributed(attrStr: NSMutableAttributedString, #range: NSRange) -> NSMutableAttributedString {
    
    attrStr.removeAttribute(kCTForegroundColorAttributeName as! String, range: range)
    attrStr.addAttribute(kCTForegroundColorAttributeName as! String, value: UIColor.colorWithHexString(kLinkColor).CGColor, range: range)
    
    return attrStr
}