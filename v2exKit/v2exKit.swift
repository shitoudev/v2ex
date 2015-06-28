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