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
import SnapKit

class PostDetailViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var postId: Int!
    var postDetail: PostDetailModel! {
        didSet {
            self.title = (self.postDetail != nil) ? self.postDetail?.title : "加载中...."
        }
    }
    var dataSouce: [AnyObject] = [AnyObject]()
    var indexPath: NSIndexPath!
    var refreshControl: UIRefreshControl!
    var atTableView: AtUserTableView!
    
    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary?) -> PostDetailViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("postDetailViewController") as! PostDetailViewController
        viewController.hidesBottomBarWhenPushed = true
        
        return viewController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.postDetail = nil
        tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "commentCellId")
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let footerView = UIView.new()
        footerView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = footerView
        
        self.refreshControl = UIRefreshControl(frame: self.tableView.bounds)
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(self.refreshControl)
        
        reloadTableViewData(isPull: false)
        
        let topLayer = CALayer()
        topLayer.frame = CGRect(x: 0, y: 0, width: toolbarView.width, height: 0.5)
        topLayer.backgroundColor = UIColor.lightGrayColor().CGColor
        toolbarView.layer.addSublayer(topLayer)

        let sendButton = toolbarView.viewWithTag(11) as! UIButton
        sendButton.addTarget(self, action: "sendButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        getTextView().delegate = self
        getTextView().placeHolder = "添加评论 输入@自动匹配用户..."
        getTextView().keyboardType = UIKeyboardType.Twitter
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        view.keyboardTriggerOffset = self.toolbarView.height;
        view.addKeyboardPanningWithActionHandler { (keyboardFrameInView, opening, closing) -> Void in
            self.view.layoutIfNeeded()
            self.toolbarBottomConstraint.constant = self.view.height - keyboardFrameInView.origin.y
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeObservers()
        view.removeKeyboardControl()
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
                            let parser = HTMLParser(html: str!, encoding: NSUTF8StringEncoding, option: CInt(HTML_PARSE_NOERROR.value | HTML_PARSE_RECOVER.value), error: &err)
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
        tableView.beginUpdates()
        
        dataSouce.append(comment)
        let row = tableView.numberOfRowsInSection(0)
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
        
        tableView.endUpdates()
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        
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

// MARK: TTTAttributedLabelDelegate
extension PostDetailViewController: TTTAttributedLabelDelegate {
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
                    let webViewController = WebViewController()
                    webViewController.loadURLWithString(url.absoluteString!)
                    navigationController?.pushViewController(webViewController, animated: true)
                }
            }
        }
    }
}

// MARK: AtUserTableViewDelegate
extension PostDetailViewController: AtUserTableViewDelegate {
    func didSelectedUser(user: MemberModel) {
        
        getTextView().text = getTextView().text.stringByReplacingOccurrencesOfString("@" + atTableView.searchText, withString: "@" + user.username + " ", options: NSStringCompareOptions.BackwardsSearch)
        
        atTableView?.hidden = true
    }
}

// MARK: UITextViewDelegate
extension PostDetailViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        if !textView.text.isEmpty && dataSouce.count > 0 {
            if last(textView.text) == " " {
                atTableView?.hidden = true
                return
            }
            let components = textView.text.componentsSeparatedByString(" ")
            if components.count > 0 {
                let atText = components.last!
                let text = atText.stringByReplacingOccurrencesOfString("@", withString: "")
                if atText.hasPrefix("@") && !text.isEmpty {
                    if atTableView == nil {
                        self.atTableView = AtUserTableView(frame: tableView.bounds, style: .Plain)
                        atTableView.atDelegate = self
                        view.insertSubview(atTableView, belowSubview: toolbarView)
                        
                        atTableView.snp_makeConstraints { (make) -> Void in
                            make.top.equalTo(tableView.snp_top).offset(64)
                            make.left.equalTo(tableView.snp_left)
                            make.right.equalTo(tableView.snp_right)
                            make.bottom.equalTo(tableView.snp_bottom)
                        }
                        let postDetail: PostDetailModel = dataSouce.first as! PostDetailModel
                        var userData = [postDetail.member]
                        for obj in dataSouce {
                            if let comment = obj as? CommentModel where userData.count > 0 {
                                var canAdd = true
                                for user in userData {
                                    if user.username == comment.member.username {
                                        canAdd = false
                                    }
                                }
                                if canAdd {
                                    userData.append(comment.member)
                                }
                            }
                        }
                        atTableView.originData = userData
                    }
                    
                    atTableView.searchText = text
                    atTableView.hidden = !atTableView.searchMember()
                } else {
                    atTableView?.hidden = true
                }
            }
        } else {
            atTableView?.hidden = true
        }
        
    }
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension PostDetailViewController: UITableViewDelegate, UITableViewDataSource {
    // UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell: PostContentCell = tableView.dequeueReusableCellWithIdentifier("postContentCellId") as! PostContentCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.contentLabel.delegate = self
            cell.updateCell(postDetail)
            
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
    
    // UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}