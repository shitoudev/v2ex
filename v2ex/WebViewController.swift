//
//  WebViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var requestURL:String = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "加载中..."
        self.webView.delegate = self
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: requestURL)!))
    }
    
    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary) -> WebViewController {
        
        var web = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("webViewController") as! WebViewController
        web.requestURL = args["url"] as! String
        
        return web
    }
    
    // MARK: UIWebViewDelegate
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        self.title = "加载失败"
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        var title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        title = title?.stringByReplacingOccurrencesOfString("- V2EX", withString: "", options: NSStringCompareOptions.BackwardsSearch, range: nil)
        self.title = title
    }

}