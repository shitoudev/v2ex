//
//  STView.swift
//  v2ex
//
//  Created by zhenwen on 6/7/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

extension UIView {
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    var right: CGFloat {
        return self.left + self.width
    }
    
    var top: CGFloat {
        return self.frame.origin.y
    }
    var bottom: CGFloat {
        return self.top + self.height
    }
    
    var width: CGFloat {
        return self.frame.size.width
    }
    var height: CGFloat {
        return self.frame.size.height
    }
    
    func traverseResponderChainForUIViewController() -> UIViewController? {
        
        if let nextResponder = self.nextResponder() {
            if nextResponder.isKindOfClass(UIViewController) {
                return (nextResponder as! UIViewController)
            }else if (nextResponder.isKindOfClass(UIView)){
                let view = nextResponder as! UIView
                return view.traverseResponderChainForUIViewController()
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
}