//
//  ProfileViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/10/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

//    var rows = 0, sections = 0
    var userInfo: MemberModel! {
        didSet {
            self.navigationItem.title = userInfo.username
        }
    }
    var username: String = "Livid"
//    var arr = [AnyObject]()
    var indexPath: NSIndexPath?

    var datasource: NSArray! {
        didSet {
            self.tableView.reloadData()
        }
    }
    
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

        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        MemberModel.getUserInfo(self.username, completionHandler: { (obj, error) -> Void in
            if error == nil {
                self.userInfo = obj
//                self.sections = 1
//                self.rows = 1
                var more = [AnyObject]()
                if self.userInfo.website != "" {
                    let content = ["text":(self.userInfo.website)!, "font":String.fontAwesomeIconWithName(FontAwesome.Sitemap), "url":self.userInfo.website!]
                    more.append(content)
                }
                if self.userInfo.twitter != "" {
                    let content = ["text":(self.userInfo.twitter)!, "font":String.fontAwesomeIconWithName(FontAwesome.Twitter), "url":"http://twitter.com/"+self.userInfo.twitter!]
                    more.append(content)
                }
                if self.userInfo.psn != "" {
                    let content = ["text":(self.userInfo.psn)!, "font":String.fontAwesomeIconWithName(FontAwesome.Sitemap), "url":"https://secure.us.playstation.com/logged-in/trophies/public-trophies/?onlineId="+self.userInfo.psn!]
                    more.append(content)
                }
                if self.userInfo.github != "" {
                    let content = ["text":(self.userInfo.github)!, "font":String.fontAwesomeIconWithName(FontAwesome.Github), "url":"https://github.com/"+self.userInfo.github!]
                    more.append(content)
                }
                if self.userInfo.btc != "" {
                    let content = ["text":(self.userInfo.btc)!, "font":String.fontAwesomeIconWithName(FontAwesome.Btc), "url":"http://blockexplorer.com/address/"+self.userInfo.btc!]
                    more.append(content)
                }
                if self.userInfo.location != "" {
                    let content = ["text":(self.userInfo.location)!, "font":String.fontAwesomeIconWithName(FontAwesome.LocationArrow), "url":"http://www.google.com/maps?q="+self.userInfo.location!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!]
                    more.append(content)
                }
                if self.userInfo.tagline != "" {
//                    var content = ["text":(self.userInfo.tagline)!, "font":String.fontAwesomeIconWithName(FontAwesome.Sitemap)]
//                    more.append(content)
                }
                
                var arr = [AnyObject]()
                arr.append([1])
                arr.append(more)
                self.datasource = arr
            }
        })
        
//        var accountViewController = AccountViewController().allocWithRouterParams(nil)
//        self.addChildViewController(accountViewController)
//        self.view.addSubview(accountViewController.view)
//        accountViewController.didMoveToParentViewController(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (indexPath != nil) {
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        var str = arr[indexPath.section][indexPath.row]
//        println("section = \(indexPath.section), row = \(indexPath.row), str = \(str)")

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
        }else if indexPath.section==1 {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("userInfoMoreID") as! UITableViewCell
            
            let dict = datasource[indexPath.section][indexPath.row] as! NSDictionary
            let str = dict["text"] as! String
            let font = dict["font"] as! String
            cell.textLabel?.text = font + "  " + str
            cell.textLabel?.font = UIFont.fontAwesomeOfSize(14)
            
            return cell
        }else{
            return UITableViewCell()
        }
//
//        let article = hotArticleArr[indexPath.row]
//        cell.updateCell(article)
//        
//        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (datasource != nil) {
            let rows = datasource[section] as! NSArray
            return rows.count
        }
        return 0
//        return arr[section];
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (datasource != nil) {
            return datasource.count
        }
        return 0
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 {
            self.indexPath = indexPath
            
            let dict = datasource[indexPath.section][indexPath.row] as! NSDictionary
            let url = dict["url"] as! String
            let webViewController = WebViewController().allocWithRouterParams(["url":url])
            webViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
}