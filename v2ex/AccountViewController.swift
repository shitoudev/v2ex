//
//  AccountViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/19/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

enum SwitchType: Int {
    case LOGIN
    case FORGOT_PASSWORD
}

struct ViewTag {
    static let textField = 10
    static let submitButton = 10
    static let forgotButton = 11
    static let captchaView = 12
}

class AccountViewController: UITableViewController {
    
    var rows = 3, sections = 1
    var type: SwitchType = .LOGIN {
        didSet {
            self.rows = type == .FORGOT_PASSWORD ? 5 : 3
            self.parentViewController?.navigationItem.title = type==SwitchType.LOGIN ? "登录" : "找回密码"
        }
    }
    var logining = false
    var once: String?
    
    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary?) -> AccountViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("accountViewController") as! AccountViewController
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .None
        self.parentViewController?.navigationItem.title = "登录"

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
            let textField = cell.viewWithTag(ViewTag.textField) as! UITextField
            resetTextField(textField)
            if type == .LOGIN {
                textField.placeholder = "用户名/邮箱地址"
                textField.keyboardType = .EmailAddress
            }else if type == .FORGOT_PASSWORD {
                textField.placeholder = "用户名"
            }
        }else if indexPath.row==1 {
            let textField = cell.viewWithTag(ViewTag.textField) as! UITextField
            resetTextField(textField)
            if type == .LOGIN {
                textField.placeholder = "密码"
                textField.secureTextEntry = true
            }else if type == .FORGOT_PASSWORD {
                textField.placeholder = "注册邮箱"
                textField.keyboardType = .EmailAddress
            }
        }else if indexPath.row==2 {
            if type == .LOGIN {
                updateSubmitButton(cell)
            } else if type == .FORGOT_PASSWORD {
                let textField = cell.viewWithTag(ViewTag.textField) as! UITextField
                resetTextField(textField)
                textField.placeholder = "验证码"
            }
        }else if indexPath.row==3 {
            let imageView = cell.viewWithTag(ViewTag.captchaView) as! UIImageView
            if let captchaOnce = once {
                APIManage.sharedManager.request(.GET, APIManage.Router.Captcha + "?once=" + captchaOnce).responseData({ (response) -> Void in
                    if response.result.isSuccess {
                        imageView.image = UIImage(data: response.result.value!)
                    }
                })
            }
        }else if indexPath.row==4 {
            updateSubmitButton(cell)
        }
    }
    
    func resetTextField(textField: UITextField) {
        textField.text = ""
        textField.placeholder = ""
        textField.clearButtonMode = UITextFieldViewMode.WhileEditing
        textField.keyboardType = .Default
        textField.secureTextEntry = false
    }
    
    func updateSubmitButton(cell: UITableViewCell) {
        let submit = cell.viewWithTag(ViewTag.submitButton) as! UIButton
        submit.addTarget(self, action: "loginSubmit:", forControlEvents: UIControlEvents.TouchUpInside)
        var title = (type == .LOGIN) ? "登录" : "找回密码"
        submit.setTitle(title, forState: UIControlState.Normal)
        let forgotPwd = cell.viewWithTag(ViewTag.forgotButton) as! UIButton
        forgotPwd.addTarget(self, action: "forgotPwd:", forControlEvents: UIControlEvents.TouchUpInside)
        title = (type == .LOGIN) ? "忘记密码？" : "我要登录"
        forgotPwd.setTitle(title, forState: UIControlState.Normal)
    }
    
    // MARK: button tapped

    // login
    func loginSubmit(sender: UIButton) {
        guard let account = self.getAccountField().text, second = self.getSecondField().text where (!logining  && !account.isEmpty && !second.isEmpty) else {
            return
        }
        
        if type == .LOGIN {
            logining = true
            JDStatusBarNotification.showWithStatus("登录中...", styleName: JDStatusBarStyleDark)
            JDStatusBarNotification.showActivityIndicator(true, indicatorStyle: UIActivityIndicatorViewStyle.White)
            
            let signinUrl = APIManage.Router.Signin
            let mgr = APIManage.sharedManager
            mgr.request(.GET, signinUrl, parameters: nil).responseString(encoding: NSUTF8StringEncoding, completionHandler: { (response) -> Void in
                if !response.result.isSuccess {
                    JDStatusBarNotification.showWithStatus("请求once失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                    return
                }
                if let once = APIManage.getOnceStringFromHtmlResponse(response.result.value!) {
                    // 请求登录
                    mgr.request(.POST, signinUrl, parameters: ["u":account, "p":second, "once":once, "next":"/"], encoding: .URL, headers: ["Referer": signinUrl]).responseString(encoding: NSUTF8StringEncoding, completionHandler: { (response) -> Void in
                        if response.result.isSuccess {
                            guard let doc = HTML(html: response.result.value!, encoding: NSUTF8StringEncoding) else {
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
                            } else if let divProblem = body.at_css("div[class='problem']"), liNode = divProblem.at_css("li"), problem = liNode.text {
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
        } else if (type == .FORGOT_PASSWORD) {
            guard let captcha = getCaptchaField().text else {
                return
            }
            JDStatusBarNotification.showWithStatus("提交中...", styleName: JDStatusBarStyleDark)
            JDStatusBarNotification.showActivityIndicator(true, indicatorStyle: UIActivityIndicatorViewStyle.White)
            
            let mgr = APIManage.sharedManager
            mgr.request(.POST, APIManage.Router.FindPwd, parameters: ["u":account, "e":second, "c":captcha, "once":self.once!], encoding: .URL, headers: ["Referer":APIManage.Router.FindPwd]).responseString(encoding: NSUTF8StringEncoding, completionHandler: { (response) -> Void in
                if response.result.isSuccess {
                    guard let doc = HTML(html: response.result.value!, encoding: NSUTF8StringEncoding) else {
                        JDStatusBarNotification.showWithStatus("数据解析失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                        return
                    }
                    
                    let body = doc.body!
                    if let divProblem = body.at_css("div[class='problem']"), liNode = divProblem.at_css("li"), problem = liNode.text {
                        // 登录出错
                        JDStatusBarNotification.showWithStatus(problem, dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                    } else {
                        JDStatusBarNotification.showWithStatus("请求成功，请注意查收邮件:]", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleSuccess)
                        self.getAccountField().text = ""; self.getSecondField().text = ""; self.getCaptchaField().text = ""
                    }
                }else{
                    JDStatusBarNotification.showWithStatus("请求失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                }
            })
        }
    }
    // forgot password
    func forgotPwd(sender: UIButton) {
        type = (type == .LOGIN) ? .FORGOT_PASSWORD : .LOGIN
        
        if type == .FORGOT_PASSWORD {
            APIManage.sharedManager.request(.GET, APIManage.Router.FindPwd).responseString(encoding: NSUTF8StringEncoding) { (response) -> Void in
                if response.result.isSuccess, let once = APIManage.getOnceStringFromHtmlResponse(response.result.value!) {
                    self.once = once
                    self.tableView.reloadData()
                }
            }
        }

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
        return textField(0)
    }
    
    func getSecondField() -> UITextField {
        return textField(1)
    }
    
    func getCaptchaField() -> UITextField {
        return textField(2)
    }
    func textField(row: Int) -> UITextField {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))
        let textField = cell!.viewWithTag(ViewTag.textField) as! UITextField
        return textField
    }
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension AccountViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier = isShowSubmitButton(indexPath) ? "submitID" : "textFieldID";
        if (indexPath.row==3 && type==SwitchType.FORGOT_PASSWORD) {
            identifier = "captchaID"
        }
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
        return isShowSubmitButton(indexPath) ? 106 : 76
    }
    func isShowSubmitButton(indexPath: NSIndexPath) -> Bool {
        return (indexPath.row==2 && type==SwitchType.LOGIN) || (indexPath.row==4 && type==SwitchType.FORGOT_PASSWORD)
    }
}
