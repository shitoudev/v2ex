//
//  STInsetLabel.swift
//  v2ex
//
//  Created by zhenwen on 7/31/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class STInsetLabel: UILabel {
    
    var padding = UIEdgeInsetsMake(0, 10, 0, 10) //UIEdgeInsetsZero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal convenience init(frame: CGRect, inset:UIEdgeInsets) {
        self.init(frame: frame)
        self.padding = inset
    }
    
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, padding))
    }
}