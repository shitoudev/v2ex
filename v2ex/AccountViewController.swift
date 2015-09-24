//
//  AccountViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/19/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import Alamofire
import JDStatusBarNotification
import Kanna

enum SwitchType: Int {
    case LOGIN
    case FORGET_PASSWORD
}

class AccountViewController: UITableViewController {
    
    let TEXT_FIELD_TAG = 10
    let SUBMIT_TAG = 10
    let FORGET_PWD = 11
    
    let rows = 3, sections = 1
    var type: SwitchType = .LOGIN
    var logining = false
    
    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary?) -> AccountViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("accountViewController") as! AccountViewController
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .None

        if let pvc = parentViewController where pvc is UINavigationController {
            navigationItem.title = "登录"
            let item = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel:")
            navigationItem.leftBarButtonItem = item
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.addKeyboardPanningWithActionHandler { (keyboardFrameInView, opening, closing) -> Void in}
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeKeyboardControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let title = (type == .LOGIN) ? "登录" : "找回密码"
            submit.setTitle(title, forState: UIControlState.Normal)
            let forgetPwd = cell.viewWithTag(FORGET_PWD) as! UIButton
            forgetPwd.hidden = true
//            forgetPwd.addTarget(self, action: "forgetPwd:", forControlEvents: UIControlEvents.TouchUpInside)
//            title = (type == .LOGIN) ? "忘记密码？" : "我要登录"
//            forgetPwd.setTitle(title, forState: UIControlState.Normal)
        }
    }
    
    // MARK: button tapped

    // login
    func loginSubmit(sender: UIButton) {
        guard let account = self.getAccountField().text, password = self.getSecondField().text where (!logining && type == .LOGIN  && !account.isEmpty && !password.isEmpty) else {
            return
        }

        logining = true
        JDStatusBarNotification.showWithStatus("登录中...", styleName: JDStatusBarStyleDark)
        JDStatusBarNotification.showActivityIndicator(true, indicatorStyle: UIActivityIndicatorViewStyle.White)
        
        let signinUrl = APIManage.Router.Signin
        let mgr = APIManage.sharedManager
        mgr.request(.GET, signinUrl, parameters: nil).responseString(encoding: NSUTF8StringEncoding, completionHandler: { (req, resp, str) -> Void in
            if !str.isSuccess {
                JDStatusBarNotification.showWithStatus("请求once失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                return
            }
            if let once = APIManage.getOnceStringFromHtmlResponse(str.value!) {
                // 请求登录
                mgr.request(.POST, signinUrl, parameters: ["u":account, "p":password, "once":once, "next":"/"], encoding: .URL, headers: ["Referer": signinUrl]).responseString(encoding: NSUTF8StringEncoding, completionHandler: { (req, resp, str) -> Void in
                    if str.isSuccess {
                        guard let doc = HTML(html: str.value!, encoding: NSUTF8StringEncoding) else {
                            JDStatusBarNotification.showWithStatus("数据解析失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                            return
                        }
                        
                        let body = doc.body!
                        if let _ = body.at_css("a[class='balance_area']") {
                            // 登录成功，查找 username
                            var username = account
                            if let spanNode = body.at_css("span[class='bigger']"), nameNode = spanNode.at_css("a"), nameText = nameNode.text {
                                username = nameText
                            }
                            // 获取用户信息
                            MemberModel.getUserInfo(username, completionHandler: { (obj, error) -> Void in
                                if error == nil {
                                    JDStatusBarNotification.showWithStatus("登录成功:]", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleSuccess)
                                    // 设置用户信息
                                    MemberModel.sharedMember.username = obj!.username
                                    MemberModel.sharedMember.uid = obj!.uid
                                    MemberModel.sharedMember.avatar_large = obj!.avatar_large
                                    MemberModel.sharedMember.saveUserData()
                                    // 重新启动通知轮询
                                    NotificationManage.sharedManager.timerRestart()
                                    NSNotificationCenter.defaultCenter().postNotificationName(v2exUserLoginSuccessNotification, object: nil, userInfo: ["user":obj!])
                                    if let pvc = self.parentViewController {
                                        if pvc is UINavigationController {
                                            self.dismissViewControllerAnimated(false, completion: { () -> Void in })
                                        }
                                    }
                                } else {
                                    JDStatusBarNotification.showWithStatus(error!.localizedDescription + "登录失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                                }
                            })
                        } else if let divProblem = doc.at_css("div[class='problem']"), liNode = divProblem.at_css("li"), problem = liNode.text {
                            // 登录出错
                            JDStatusBarNotification.showWithStatus(problem, dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                        } else {
                            JDStatusBarNotification.showWithStatus("登录失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                        }
                    }else{
                        JDStatusBarNotification.showWithStatus("请求登录失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                    }
                    self.logining = false
                })
            } else {
                // once 获取失败
                self.logining = false
                JDStatusBarNotification.showWithStatus("once 获取失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
            }
        })
    }
    // forget password
    func forgetPwd(sender: UIButton) {
        type = (type == .LOGIN) ? .FORGET_PASSWORD : .LOGIN

        UIView.transitionWithView(self.tableView, duration: 0.5, options: UIViewAnimationOptions.OverrideInheritedDuration, animations: { () -> Void in
            self.tableView.reloadData()
        }) { (finished) -> Void in
            
        }
    }
    
    // MARK: Action
    
    func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    // MARK: Get View
    
    func getAccountField() -> UITextField {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        let textField = cell!.viewWithTag(TEXT_FIELD_TAG) as! UITextField
        return textField
    }
    
    func getSecondField() -> UITextField {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        let textField = cell!.viewWithTag(TEXT_FIELD_TAG) as! UITextField
        return textField
    }
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension AccountViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = indexPath.row==2 ? "submitID" : "textFieldID";
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier)!
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
}
