//
//  WebViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import v2exKit

class WebViewController: BaseViewController {
    
    var webView: WKWebView!
    var toolbar: UIToolbar!
    var backButtonItem: UIBarButtonItem!
    var forwardButtonItem: UIBarButtonItem!
    var refreshButtonItem: UIBarButtonItem!
    var moreButtonItem: UIBarButtonItem!
    var progressView: UIProgressView!
    var urlString: String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    func commonInit() {
        
        edgesForExtendedLayout = .None
        hidesBottomBarWhenPushed = true
        self.webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        self.backButtonItem = UIBarButtonItem(image: UIImage(named: "webBack"), style: UIBarButtonItemStyle.Plain, target: self, action: "backTapped:")
        self.forwardButtonItem = UIBarButtonItem(image: UIImage(named: "webForward"), style: UIBarButtonItemStyle.Plain, target: self, action: "forwardTapped:")
        self.refreshButtonItem = UIBarButtonItem(image: UIImage(named: "webRefresh"), style: UIBarButtonItemStyle.Plain, target: self, action: "refreshTapped:")
        self.moreButtonItem = UIBarButtonItem(image: UIImage(named: "webMore"), style: UIBarButtonItemStyle.Plain, target: self, action: "moreTapped:")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let flexibleSpace2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let flexibleSpace3 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        self.toolbar = UIToolbar()
        toolbar.translucent = false
        toolbar.items = [backButtonItem, flexibleSpace, forwardButtonItem, flexibleSpace2, refreshButtonItem, flexibleSpace3, moreButtonItem]

        view.addSubview(toolbar)

        webView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topLayoutGuide)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(toolbar.snp_top)
        }
        
        toolbar.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(webView.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(bottomLayoutGuide)
        }
        
        self.progressView = UIProgressView()
        progressView.progressTintColor = UIColor.whiteColor()
        view.addSubview(progressView)
        
        progressView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.height.equalTo(2.5)
            make.top.equalTo(view.snp_top)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        if webView.loading {
            webView.stopLoading()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "加载中..."
    }
    
    func loadURLWithString(urlString: String) {
        if let URL = NSURL(string: urlString) {
            if (!URL.scheme.isEmpty) && (URL.host != nil) {
                self.urlString = urlString
                loadURL(URL)
                return
            } else {
                loadURLWithString("http://\(urlString)")
                return
            }
        }
    }
    
    func loadURL(URL: NSURL, cachePolicy: NSURLRequestCachePolicy = .UseProtocolCachePolicy, timeoutInterval: NSTimeInterval = 0) {
        webView.loadRequest(NSURLRequest(URL: URL, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval))
    }
    
    // MARK: KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let key = keyPath else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }

        switch key {
            case "estimatedProgress":
                if let newValue = change?[NSKeyValueChangeNewKey] as? NSNumber {
                    progressChanged(newValue)
                }
            default: break
        }
    }
    
    func progressChanged(newValue: NSNumber) {
        progressView.progress = newValue.floatValue
        if progressView.progress >= 1 {
            progressView.progress = 0
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.progressView.alpha = 0
            })
        } else if progressView.alpha == 0 {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.progressView.alpha = 1
            })
        }
    }
    
    // MARK: Button tapped
    func backTapped(sender: AnyObject) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    func forwardTapped(sender: AnyObject) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    func refreshTapped(sender: AnyObject) {
        if webView.loading {
            webView.stopLoading()
            updateToolbarItems()
            title = "加载取消"
        } else {
            if let _ = webView.URL {
                webView.reload()
            } else {
                if urlString != nil {
                    title = "加载中..."
                    loadURLWithString(urlString!)
                }
            }
        }
    }
    
    func moreTapped(sender: AnyObject) {
        let alertViewController = UIAlertController(title: "更多操作", message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: { (_) -> Void in })
        let copyAction = UIAlertAction(title: "复制链接", style: .Default, handler: { (action) -> Void in
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = self.webView.URL?.absoluteString
        })
        let safariAction = UIAlertAction(title: "在Safari中浏览", style: .Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(self.webView.URL!)
        }
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(copyAction)
        alertViewController.addAction(safariAction)
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "googlechrome://")!) {
            let chromeAction = UIAlertAction(title: "在Chrome中浏览", style: .Default) { (action) -> Void in
                
                let inputURL = self.webView.URL!
                let scheme = inputURL.scheme
                
                // Replace the URL Scheme with the Chrome equivalent.
                var chromeScheme = ""
                if scheme == "http" {
                    chromeScheme = "googlechrome";
                } else if scheme == "https" {
                    chromeScheme = "googlechromes";
                }
                
                // Proceed only if a valid Google Chrome URI Scheme is available.
                if !chromeScheme.isEmpty {
                    let absoluteString = inputURL.absoluteString
                    let rangeForScheme = absoluteString.rangeOfString(":")!
                    
                    let urlNoScheme = absoluteString.substringFromIndex(rangeForScheme.startIndex)
                    let chromeURL = NSURL(string: chromeScheme.stringByAppendingString(urlNoScheme))!
                    UIApplication.sharedApplication().openURL(chromeURL)
                }
            }
            alertViewController.addAction(chromeAction)
        }
        
        // iPad
        if let popoverController = alertViewController.popoverPresentationController {
            popoverController.sourceView = toolbar
            popoverController.sourceRect = toolbar.bounds
        }
        presentViewController(alertViewController, animated: true, completion: { () -> Void in })
    }
    /// Update toolbar
    func updateToolbarItems() {
        backButtonItem.enabled = webView.canGoBack
        forwardButtonItem.enabled = webView.canGoForward
        moreButtonItem.enabled = !webView.loading
        refreshButtonItem.image = webView.loading ? UIImage(named: "webStop") : UIImage(named: "webRefresh")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = webView.loading
    }
}

// MARK: WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateToolbarItems()
    }
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        title = webView.title
        updateToolbarItems()
    }
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        updateToolbarItems()
    }
}