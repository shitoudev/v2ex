//
//  AccountViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/19/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import Alamofire

enum SwitchType: Int {
    case LOGIN
    case FORGET_PASSWORD
}

class AccountViewController: UITableViewController {
    
    let TEXT_FIELD_TAG = 10
    let SUBMIT_TAG = 10
    let FORGET_PWD = 11
    
    var rows = 3, sections = 1
    var type: SwitchType = .LOGIN
    
    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary?) -> AccountViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("accountViewController") as! AccountViewController
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorStyle = .None
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = indexPath.row==2 ? "submitID" : "textFieldID";
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! UITableViewCell
        cell.selectionStyle = .None
        self.updateCellUI(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows;
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row==2 ? 106 : 76
    }
    
    // MARK: Update cell ui
    /**
    更新cell ui
    
    :param: cell      单个cell
    :param: indexPath indexPath
    */
    func updateCellUI(cell: UITableViewCell, indexPath: NSIndexPath) {
        if indexPath.row==0 {
            let textField = cell.viewWithTag(TEXT_FIELD_TAG) as! UITextField
            textField.text = ""
            textField.clearButtonMode = UITextFieldViewMode.WhileEditing
            if type == .LOGIN {
                textField.placeholder = "用户名/邮箱地址"
                textField.secureTextEntry = false
                textField.keyboardType = .EmailAddress
            }else if type == .FORGET_PASSWORD {
                textField.placeholder = "用户名"
                textField.secureTextEntry = false
                textField.keyboardType = .Default
            }
        }else if indexPath.row==1 {
            let textField = cell.viewWithTag(TEXT_FIELD_TAG) as! UITextField
            textField.text = ""
            textField.clearButtonMode = UITextFieldViewMode.WhileEditing
            if type == .LOGIN {
                textField.placeholder = "密码"
                textField.secureTextEntry = true
                textField.keyboardType = .Default
            }else if type == .FORGET_PASSWORD {
                textField.placeholder = "注册邮箱"
                textField.secureTextEntry = false
                textField.keyboardType = .EmailAddress
            }
        }else if indexPath.row==2 {
            let submit = cell.viewWithTag(SUBMIT_TAG) as! UIButton
            submit.addTarget(self, action: "loginSubmit:", forControlEvents: UIControlEvents.TouchUpInside)
            var title = (type == .LOGIN) ? "登录" : "找回密码"
            submit.setTitle(title, forState: UIControlState.Normal)
            let forgetPwd = cell.viewWithTag(FORGET_PWD) as! UIButton
            forgetPwd.addTarget(self, action: "forgetPwd:", forControlEvents: UIControlEvents.TouchUpInside)
            title = (type == .LOGIN) ? "忘记密码？" : "我要登录"
            forgetPwd.setTitle(title, forState: UIControlState.Normal)
            
            if type == .LOGIN {
                
            }
        }
    }
    
    // MARK: button tapped

    // login
    func loginSubmit(sender: UIButton) {
        if type == .LOGIN {
            
            let signinUrl = APIManage.Router.Signin
            
//            let cfg = NSURLSessionConfiguration.defaultSessionConfiguration()
            let cookiesStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
//            cfg.HTTPCookieStorage = cookiesStorage
//            cfg.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
//            cfg.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
//            cfg.HTTPAdditionalHeaders?.updateValue(signinUrl, forKey: "Referer")
            
            for cookie in cookiesStorage.cookies as! [NSHTTPCookie] {
                if cookie.domain.hasSuffix(APIManage.domain) {
                    cookiesStorage.deleteCookie(cookie)
                }
            }
            println("cookies = \(cookiesStorage.cookies)")


            let mgr = APIManage.sharedManager //Alamofire.Manager(configuration: cfg)

            mgr.request(.GET, signinUrl, parameters: nil).responseString(encoding: nil, completionHandler: { (req, resp, str, error) -> Void in
                
                var err: NSError?
                var parser = HTMLParser(html: str!, error: &err)
                
                var bodyNode = parser.body
                if let onceNode = bodyNode?.findChildTagAttr("input", attrName: "name", attrValue: "once") {
                    let once = onceNode.getAttributeNamed("value")
                    mgr.session.configuration.HTTPAdditionalHeaders?.updateValue(signinUrl, forKey: "Referer")
                    // 请求登录
                    mgr.request(.POST, signinUrl, parameters: ["u":"wordcup", "p":"wordcup", "once":once, "next":"/"]).responseString(encoding: nil, completionHandler: { (req, resp, str, error) -> Void in
                        if (error != nil && str != nil) {
                            var err: NSError?
                            var parser = HTMLParser(html: str!, error: &err)
                            var bodyNode = parser.body
                            if let myNodes = bodyNode?.findChildTagAttr("a", attrName: "href", attrValue: "/my/nodes") {
                                // 登录成功
                                
                            }
                        }else{
                            
                        }
                        println("resp = \(resp), obj = \(str), error = \(error)")
//                            println("cookies___ = \(mgr.session.configuration.HTTPCookieStorage?.cookies)")

                    })
                }
                
            })
            
        }
    }
    // forget password
    func forgetPwd(sender: UIButton) {
        type = (type == .LOGIN) ? .FORGET_PASSWORD : .LOGIN

        UIView.transitionWithView(self.tableView, duration: 0.5, options: UIViewAnimationOptions.OverrideInheritedDuration, animations: { () -> Void in
            self.tableView.reloadData()
        }) { (finished) -> Void in
            
        }
    }
    
    
}
