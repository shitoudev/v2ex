//
//  ProfileViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/10/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

//    var rows = 0, sections = 0
    var isMine = true
    var userInfo: MemberModel! {
        didSet {
            self.navigationItem.title = userInfo==nil ? "我的" : userInfo.username
        }
    }
    var username: String! {
        didSet {
            MemberModel.getUserInfo(username, completionHandler: { (obj, error) -> Void in
//                println("userInfo.bio = \(obj!.bio)")
                if error == nil {
                    self.userInfo = obj
                    self.updateUI()
                } else {
                    self.navigationItem.title = error!.localizedDescription
                }
            })
        }
    }

    var indexPath: NSIndexPath?

    var datasource: [AnyObject]! {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var accountViewController: AccountViewController?
    
    lazy var box = UIView()
    
    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary?) -> ProfileViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "我的"

        tableView.backgroundColor = UIColor.whiteColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        if isMine {
            if MemberModel.sharedMember.isLogin() {
                username = MemberModel.sharedMember.username
            } else {
                addAccountViewController()
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLoginSuccess:", name: v2exUserLoginSuccessNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (indexPath != nil) {
            tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }
    
    func addAccountViewController() {
        self.accountViewController = AccountViewController().allocWithRouterParams(nil)
        addChildViewController(accountViewController!)
        view.addSubview(accountViewController!.view)
        accountViewController!.didMoveToParentViewController(self)
    }
    
    func updateUI() {
        var more = [AnyObject]()
        if userInfo.website != "" {
            let content = ["text":(userInfo.website)!, "font":String.fontAwesomeIconWithName(FontAwesome.Sitemap), "url":userInfo.website!]
            more.append(content)
        }
        if userInfo.twitter != "" {
            let content = ["text":(userInfo.twitter)!, "font":String.fontAwesomeIconWithName(FontAwesome.Twitter), "url":"http://twitter.com/"+userInfo.twitter!]
            more.append(content)
        }
        if userInfo.psn != "" {
            let content = ["text":(userInfo.psn)!, "font":String.fontAwesomeIconWithName(FontAwesome.Sitemap), "url":"https://secure.us.playstation.com/logged-in/trophies/public-trophies/?onlineId="+userInfo.psn!]
            more.append(content)
        }
        if userInfo.github != "" {
            let content = ["text":(userInfo.github)!, "font":String.fontAwesomeIconWithName(FontAwesome.Github), "url":"https://github.com/"+userInfo.github!]
            more.append(content)
        }
        if userInfo.btc != "" {
            let content = ["text":(userInfo.btc)!, "font":String.fontAwesomeIconWithName(FontAwesome.Btc), "url":"http://blockexplorer.com/address/"+userInfo.btc!]
            more.append(content)
        }
        if userInfo.location != "" {
            let content = ["text":(userInfo.location)!, "font":String.fontAwesomeIconWithName(FontAwesome.LocationArrow), "url":"http://www.google.com/maps?q="+userInfo.location!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!]
            more.append(content)
        }
        if userInfo.tagline != "" {
            //                    var content = ["text":(self.userInfo.tagline)!, "font":String.fontAwesomeIconWithName(FontAwesome.Sitemap)]
            //                    more.append(content)
        }
        
        if isMine && more.count == 0 {
            more.append(["text":"退出登录"])
        }
        
        var arr = [AnyObject]()
        arr.append([1])
        arr.append(more)
        
        if isMine {
            arr.append([["text":"退出登录"]])
        }
        self.datasource = arr
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section==0 && indexPath.row==0 {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("userInfoID") as! UITableViewCell

            let avatarImageView = cell.viewWithTag(1) as! UIImageView
            avatarImageView.layer.cornerRadius = 5
            avatarImageView.layer.masksToBounds = true
            avatarImageView.kf_setImageWithURL(NSURL(string: userInfo.avatar_large)!, placeholderImage: nil)
            
            let usernameLabel = cell.viewWithTag(2) as! UILabel
            usernameLabel.text = userInfo.username
            
            let bioLabel = cell.viewWithTag(3) as! UILabel
            bioLabel.text = userInfo.bio
            
            return cell
        }else if indexPath.section==1 || indexPath.section==2 {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("userInfoMoreID") as! UITableViewCell
            
            let dict = datasource[indexPath.section][indexPath.row] as! NSDictionary
            let str = dict["text"] as! String
            if str == "退出登录" {
                cell.textLabel?.text = str
                cell.textLabel?.font = UIFont.systemFontOfSize(13)
                cell.textLabel?.textAlignment = NSTextAlignment.Center
            } else {
                let font = dict["font"] as! String
                cell.textLabel?.text = font + "  " + str
                cell.textLabel?.font = UIFont.fontAwesomeOfSize(14)
                cell.textLabel?.textAlignment = NSTextAlignment.Left
            }
            
            
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (datasource != nil) {
            let rows = datasource[section] as! [AnyObject]
            return rows.count
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (datasource != nil) {
            return datasource.count
        }
        return 0
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section==1 || indexPath.section==2 {
            self.indexPath = indexPath
            
            let dict = datasource[indexPath.section][indexPath.row] as! NSDictionary
            let str = dict["text"] as! String
            if str == "退出登录" {
                self.indexPath = nil
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                let alertViewController = UIAlertController(title: "确定要退出登录吗？", message: nil, preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: { (_) -> Void in })
                let okAction = UIAlertAction(title: "退出登录", style: .Default, handler: { (action) -> Void in
                    self.userInfo = nil
                    MemberModel.sharedMember.removeUserData()
                    self.addAccountViewController()
                    NSNotificationCenter.defaultCenter().postNotificationName(v2exUserLogoutSuccessNotification, object: nil)

                })
                alertViewController.addAction(cancelAction)
                alertViewController.addAction(okAction)
                // iPad
                if let popoverController = alertViewController.popoverPresentationController {
                    let cell = tableView.cellForRowAtIndexPath(indexPath)!
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
                presentViewController(alertViewController, animated: true, completion: { () -> Void in
                    
                })
            } else {
                let url = dict["url"] as! String
                let webViewController = WebViewController()
                webViewController.loadURLWithString(url)
                navigationController?.pushViewController(webViewController, animated: true)
            }
        }
    }
    
    // MARK: NSNotification
    
    func userLoginSuccess(notification: NSNotification) {
        if isMine {
            if (accountViewController != nil) {
                accountViewController?.view.removeFromSuperview()
                accountViewController?.removeFromParentViewController()
                self.accountViewController = nil
            }
            self.userInfo = notification.userInfo!["user"] as! MemberModel
            updateUI()
        }
    }
    
}