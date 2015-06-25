//
//  BaseViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/11/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import Kingfisher

class BaseViewController: UIViewController {
    
    var loadingView: UIActivityIndicatorView!
    var reloadView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 加载中
        self.loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingView.center = self.view.center
        loadingView.hidesWhenStopped = true
        self.view.addSubview(loadingView)
        // 重新加载按钮
        self.reloadView = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        reloadView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 40))
        reloadView.center = self.view.center
        reloadView.setTitle("点我重新加载", forState: UIControlState.Normal)
        reloadView.setTitleColor(UIColor.colorWithHexString("#333344"), forState: UIControlState.Normal)
        reloadView.titleLabel?.font = UIFont.systemFontOfSize(13.0)
        reloadView.hidden = true
        reloadView.addTarget(self, action: "reloadViewTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(reloadView)
    }
    
    func reloadViewTapped(sender: UIButton!) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

}
