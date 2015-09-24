//
//  STString.swift
//  v2ex
//
//  Created by zhenwen on 6/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

extension String {
    
    public static func strHeight (str: String, size: CGSize, font: UIFont) -> CGFloat {
//        NSStringDrawingOptions.UsesFontLeading
        let rect: CGRect = str.boundingRectWithSize(size, options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: [NSFontAttributeName:font], context: nil)
        return rect.size.height
    }
    
    public func trim() -> String {
        return self.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
    }
}
