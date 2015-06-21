//
//  PostDetailViewController.swift
//  v2ex
//
//  Created by zhenwen on 6/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import SnapKit
import JDStatusBarNotification

class PostDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var postId: Int!
    var postDetail: PostDetailModel!
    var dataSouce: NSArray! {
        didSet {
            self.title = (self.postDetail != nil) ? self.postDetail?.title : "加载中...."
            self.tableView.reloadData()
        }
    }
    var indexPath: NSIndexPath!
    var refreshControl: UIRefreshControl!
    
    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary?) -> PostDetailViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("postDetailViewController") as! PostDetailViewController
        viewController.hidesBottomBarWhenPushed = true
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSouce = []
        self.tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "commentCellId")
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let footerView = UIView.new()
        footerView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = footerView
        
        self.refreshControl = UIRefreshControl(frame: self.tableView.bounds)
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        self.reloadTableViewData(isPull: false)
        
        let topLayer = CALayer()
        topLayer.frame = CGRectMake(0, 0, toolbarView.width, 0.5)
        topLayer.backgroundColor = UIColor.lightGrayColor().CGColor
        toolbarView.layer.addSublayer(topLayer)

        let sendButton = toolbarView.viewWithTag(11) as! UIButton
        sendButton.addTarget(self, action: "sendButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addObservers()
        view.keyboardTriggerOffset = self.toolbarView.height;
        view.addKeyboardPanningWithActionHandler { (keyboardFrameInView, opening, closing) -> Void in
            self.toolbarBottomConstraint.constant = self.view.height - keyboardFrameInView.origin.y
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeObservers()
        view.removeKeyboardControl()
    }
    
    deinit {
        println("deinit call")
    }
    
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("postContentCellId") as! UITableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            let titleLabel = cell.contentView.viewWithTag(10) as! UILabel
            titleLabel.font = UIFont.boldSystemFontOfSize(14)
            titleLabel.text = postDetail.title
            
            let usernameButton = cell.contentView.viewWithTag(15) as! UIButton
            usernameButton.setTitle(postDetail.member.username, forState: UIControlState.Normal)
            
            let avatarButton = cell.contentView.viewWithTag(16) as! UIButton
            avatarButton.layer.cornerRadius = 5
            avatarButton.layer.masksToBounds = true
            avatarButton.kf_setImageWithURL(NSURL(string: self.postDetail.member.avatar_large)!, forState: .Normal, placeholderImage: nil)
            
            let timeLabel = cell.contentView.viewWithTag(13) as! UILabel
            timeLabel.font = UIFont.systemFontOfSize(12)
            timeLabel.textColor = UIColor.grayColor()
            timeLabel.text = postDetail.getSmartTime()
            
            let contentLabel = cell.contentView.viewWithTag(14) as! UILabel
            contentLabel.text = postDetail.content
            contentLabel.font = UIFont.systemFontOfSize(14)

            return cell;
            
        } else {
            let cell: CommentCell = tableView.dequeueReusableCellWithIdentifier("commentCellId") as! CommentCell
            
            let comment = dataSouce[indexPath.row] as! CommentModel
            cell.updateCell(comment)
            
            cell.avatarButton.tag = indexPath.row
            cell.usernameButton.tag = indexPath.row
            
            if !cell.isButtonAddTarget {
                cell.avatarButton.addTarget(self, action: "commentUserTapped:", forControlEvents: .TouchUpInside)
                cell.usernameButton.addTarget(self, action: "commentUserTapped:", forControlEvents: .TouchUpInside)
                cell.isButtonAddTarget = true
            }
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count > 0 ? dataSouce.count : 0
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func refresh() {
        reloadTableViewData(isPull: true)
    }
    
    func reloadTableViewData(#isPull: Bool) {
        
        PostDetailModel.getPostDetail(postId, completionHandler: { (detail, error) -> Void in
            if error == nil {
                self.postDetail = detail
                CommentModel.getComments(self.postId, completionHandler: { (obj, error) -> Void in
                    if error == nil {
                        var arr: NSMutableArray = NSMutableArray(array: obj)
                        arr.insertObject(detail!, atIndex: 0)
                        self.dataSouce = arr
                    }
                    
                    if isPull {
                        self.refreshControl.endRefreshing()
                    }
                })
            }else{
                if isPull {
                    self.refreshControl.endRefreshing()
                }
            }
        })
        
    }
    
    func postLoaded() {
        tableView.reloadData()
    }
    
    // MARK: button tapped
    @IBAction func userTapped(sender: AnyObject) {
        pushToProfileViewController(self.postDetail.member.username)
    }
    
    func commentUserTapped(sender: AnyObject) {
        let button = sender as! UIButton
        let comment = dataSouce[button.tag] as! CommentModel

        pushToProfileViewController(comment.member.username)
    }
    
    func pushToProfileViewController(username: String) {
        if username != MemberModel.sharedMember.username {
            let profileViewController = ProfileViewController().allocWithRouterParams(nil)
            profileViewController.isMine = false
            profileViewController.username = username
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
    
    func sendButtonTapped(sender: UIButton) {
        if !MemberModel.sharedMember.isLogin() {
            let accountViewController = AccountViewController().allocWithRouterParams(nil)
            presentViewController(UINavigationController(rootViewController: accountViewController), animated: true, completion: { () -> Void in
                
            })
            return
        }
        if getTextView().text.isEmpty {
            return
        }
        JDStatusBarNotification.showWithStatus("提交中...", styleName: JDStatusBarStyleDark)
        JDStatusBarNotification.showActivityIndicator(true, indicatorStyle: UIActivityIndicatorViewStyle.White)
        // get once code
        let mgr = APIManage.sharedManager //Alamofire.Manager(configuration: cfg)
        let url = APIManage.Router.Post + String(postId) // String(199762)
        mgr.request(.GET, url, parameters: nil).responseString(encoding: nil) { (req, resp, str, error) -> Void in
            
            if error == nil {
                let once = APIManage.getOnceStringFromHtmlResponse(str!)
                if !once.isEmpty {
                    // submit comment
                    mgr.session.configuration.HTTPAdditionalHeaders?.updateValue(url, forKey: "Referer")
                    mgr.request(.POST, url, parameters: ["content":self.getTextView().text, "once":once]).responseString(encoding: nil, completionHandler: { (req, resp, str, error) -> Void in
                        //                        println("args = \(self.getTextView().text + once), str = \(str)")
                        if (error == nil && str != nil) {
                            var err: NSError?
                            let parser = HTMLParser(html: str!, error: &err)
                            let bodyNode = parser.body
                            let headNode = parser.head
                            
                            if let canonical = headNode?.findChildTagAttr("link", attrName: "rel", attrValue: "canonical") {
                                // success
                                self.submitSuccessData()
                            } else {
                                var errorStr = "提交失败，错误未捕捉到:["
                                if let divNode: HTMLNode = bodyNode?.findChildTagAttr("div", attrName: "class", attrValue: "problem") {
                                    if let liNode = divNode.findChildTag("li") {
                                        errorStr = liNode.contents
                                    }
                                }
                                JDStatusBarNotification.showWithStatus(errorStr, dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                            }
                        }else{
                            JDStatusBarNotification.showWithStatus("提交失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                        }
                        //                        println("cookies___ = \(mgr.session.configuration.HTTPCookieStorage?.cookies)")
                    })
                } else {
                    JDStatusBarNotification.showWithStatus("once 获取失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
                }
            } else {
                JDStatusBarNotification.showWithStatus(error!.localizedDescription + "提交失败:[", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleWarning)
            }
            
        }
    }
    
    func submitSuccessData() {
        reloadTableViewData(isPull: false)
        JDStatusBarNotification.showWithStatus("提交完成:]", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleSuccess)
        getTextView().text = ""
        getTextView().setNeedsDisplay()
    }
    
    // MARK: Key-value observing
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        let oldContentSize = change[NSKeyValueChangeOldKey]!.CGSizeValue()
        let newContentSize = change[NSKeyValueChangeNewKey]!.CGSizeValue()
        
        let dy = newContentSize.height - oldContentSize.height
        
        toolbarHeightConstraint.constant = toolbarHeightConstraint.constant + dy
        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
    }
    
    // MARK: Utilities
    
    func addObservers() {
        getTextView().addObserver(self, forKeyPath: "contentSize", options: .Old | .New, context: nil)
    }
    
    func removeObservers() {
        getTextView().removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
    
    func getTextView() -> STTextView {
        return toolbarView.viewWithTag(10) as! STTextView
    }
    
}