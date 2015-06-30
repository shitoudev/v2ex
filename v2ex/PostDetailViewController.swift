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
import TTTAttributedLabel
import v2exKit

class PostDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var postId: Int!
    var postDetail: PostDetailModel!
    var dataSouce: [AnyObject] = [AnyObject]() {
        didSet {
            self.title = (self.postDetail != nil) ? self.postDetail?.title : "加载中...."
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeObservers()
        view.removeKeyboardControl()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
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
            titleLabel.font = kTitleFont
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
            
            let contentLabel = cell.contentView.viewWithTag(14) as! TTTAttributedLabel
            contentLabel.delegate = self
            contentLabel.font = UIFont.systemFontOfSize(14)
            var linkAttributes = Dictionary<String, AnyObject>()
            linkAttributes[kCTForegroundColorAttributeName as! String] = UIColor.colorWithHexString(kLinkColor).CGColor
            contentLabel.linkAttributes = linkAttributes
            contentLabel.extendsLinkTouchArea = false
            contentLabel.font = kContentFont
            
            var linkRange = [NSRange]()
            contentLabel.setText(postDetail.content, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString) -> NSMutableAttributedString! in
                
                let stringRange = NSMakeRange(0, mutableAttributedString.length)
                // username
                usernameRegularExpression.enumerateMatchesInString(mutableAttributedString.string, options: NSMatchingOptions.ReportCompletion, range: stringRange, usingBlock: { (result, flags, stop) -> Void in
                    
                    if result != nil {
                        addLinkAttributed(mutableAttributedString, range: result.range)
                        linkRange.append(result.range)
                    }
                })
                // http link
                httpRegularExpression.enumerateMatchesInString(mutableAttributedString.string, options: NSMatchingOptions.ReportCompletion, range: stringRange, usingBlock: { (result, flags, stop) -> Void in
                    
                    if result != nil {
                        addLinkAttributed(mutableAttributedString, range: result.range)
                        linkRange.append(result.range)
                    }
                })
                
                return mutableAttributedString
            })
            
            if linkRange.count > 0 {
                for range in linkRange {
                    let linkStr = (postDetail.content as NSString).substringWithRange(range)
                    contentLabel.addLinkToURL(NSURL(string: linkStr), withRange: range)
                }
            }

            return cell;
            
        } else {
            let cell: CommentCell = tableView.dequeueReusableCellWithIdentifier("commentCellId") as! CommentCell
            cell.contentLabel.delegate = self
            
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
//        self.postId = 199762
        PostDetailModel.getPostDetail(postId, completionHandler: { (detail, error) -> Void in
            if error == nil {
                self.dataSouce = []
                self.postDetail = detail
                self.dataSouce.append(self.postDetail)
                self.tableView.reloadData()

//                CommentModel.getCommentsFromHtml(self.postId, page: 1, completionHandler: { (obj, error) -> Void in
//                    if error == nil {
//                        self.tableView.beginUpdates()
//                        var indexPaths = [NSIndexPath]()
//                        for (index, val) in enumerate(obj) {
//                            self.dataSouce.append(val)
//
//                            let row = self.tableView.numberOfRowsInSection(0)+index
//                            let indexPath = NSIndexPath(forRow: row, inSection: 0)
//                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
//                        }
//                        self.tableView.endUpdates()
//                    }
//                    
//                    if isPull {
//                        self.refreshControl.endRefreshing()
//                    }
//                })
                
                let salt = "&\(self.postDetail.replies)"
                CommentModel.getComments(self.postId, salt:salt, completionHandler: { (obj, error) -> Void in
                    if error == nil {
                        self.tableView.beginUpdates()
                        for (index, val) in enumerate(obj) {
                            self.dataSouce.append(val)
                            
                            let row = self.tableView.numberOfRowsInSection(0)+index
                            let indexPath = NSIndexPath(forRow: row, inSection: 0)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
                        }
                        self.tableView.endUpdates()
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
            navigationController?.pushViewController(profileViewController, animated: true)
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
        
        JDStatusBarNotification.showWithStatus("提交完成:]", dismissAfter: _dismissAfter, styleName: JDStatusBarStyleSuccess)
        
        let content = getTextView().text
        let user = MemberModel.sharedMember
        let data = ["id":0, "content":content, "created":NSDate().timeIntervalSince1970, "member":["username":user.username, "avatar_large":user.avatar_large]]
        let comment = CommentModel(fromDictionary: data)
//        println("comment.data = \(data)")
        
        // update row
        self.tableView.beginUpdates()
        
        self.dataSouce.append(comment)
        let row = self.tableView.numberOfRowsInSection(0)
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
        
        self.tableView.endUpdates()
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        
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
    
    // MARK: TTTAttributedLabelDelegate
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if url != nil {
            if let urlStr = url.absoluteString {
                if urlStr.hasPrefix("@") {
                    let username = (urlStr as NSString).substringFromIndex(1)

                    let profileViewController = ProfileViewController().allocWithRouterParams(nil)
                    profileViewController.isMine = false
                    profileViewController.username = username
                    navigationController?.pushViewController(profileViewController, animated: true)
                } else {
                    let webViewController = WebViewController().allocWithRouterParams(["url":url.absoluteString!])
                    navigationController?.pushViewController(webViewController, animated: true)
                }
            }
        }
    }
    
}