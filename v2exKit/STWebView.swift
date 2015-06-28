//
//  STWebView.swift
//  v2ex
//
//  Created by zhenwen on 6/10/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class STWebView: UIWebView, UIWebViewDelegate {
    
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        let scrollView = self.subviews.first as! UIScrollView
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.bounces = false
//        scrollView.bouncesZoom = false
//        
//        self.delegate = self
//        self.scrollView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let scrollView = self.subviews.first as! UIScrollView
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.bouncesZoom = false
        
        self.delegate = self
        self.scrollView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        
    }

    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        let scrollView = object as! UIScrollView
        var rect = self.frame
        rect.size.height = scrollView.frame.size.height
        self.frame = rect
        
        NSNotificationCenter.defaultCenter().postNotificationName("notificationPostLoaded", object: nil, userInfo: nil)
    }
    
    
    // MARK: UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        request.URL?.absoluteString
        return true
    }
    
    
}
