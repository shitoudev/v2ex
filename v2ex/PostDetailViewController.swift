//
//  PostDetailViewController.swift
//  v2ex
//
//  Created by zhenwen on 6/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import SnapKit

class PostDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var webViewHeight: CGFloat = 0
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
        topLayer.frame = CGRectMake(0, 0, self.toolbarView.width, 0.5)
        topLayer.backgroundColor = UIColor.lightGrayColor().CGColor
        self.toolbarView.layer.addSublayer(topLayer)
        
        let sendButton = self.toolbarView.viewWithTag(11) as! UIButton
        sendButton.addTarget(self, action: "sendButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.keyboardTriggerOffset = self.toolbarView.height;
        self.view.addKeyboardPanningWithActionHandler { (keyboardFrameInView, opening, closing) -> Void in
            self.toolbarBottomConstraint.constant = self.view.height - keyboardFrameInView.origin.y
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.addObservers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeObservers()
        self.view.removeKeyboardControl()
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
        self.reloadTableViewData(isPull: true)
    }
    
    func reloadTableViewData(#isPull: Bool) {
        
        PostDetailModel.getPostDetail(self.postId, completionHandler: { (detail, error) -> Void in
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
        self.tableView.reloadData()
    }
    
    // MARK: button tapped
    @IBAction func userTapped(sender: AnyObject) {
        self.pushToProfileViewController(self.postDetail.member.username)
    }
    
    func commentUserTapped(sender: AnyObject) {
        let button = sender as! UIButton
        let comment = dataSouce[button.tag] as! CommentModel

        self.pushToProfileViewController(comment.member.username)
    }
    
    func pushToProfileViewController(username: String) {
        let profileViewController = ProfileViewController().allocWithRouterParams(nil)
        profileViewController.username = username
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    func sendButtonTapped(sender: UIButton) {
        
    }
    
    // MARK: Key-value observing
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        let oldContentSize = change[NSKeyValueChangeOldKey]!.CGSizeValue()
        let newContentSize = change[NSKeyValueChangeNewKey]!.CGSizeValue()
        
        let dy = newContentSize.height - oldContentSize.height
        
        self.toolbarHeightConstraint.constant = toolbarHeightConstraint.constant + dy
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }
    
    // MARK: Utilities
    
    func addObservers() {
        self.getTextView().addObserver(self, forKeyPath: "contentSize", options: .Old | .New, context: nil)
    }
    
    func removeObservers() {
        self.getTextView().removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
    
    func getTextView() -> STTextView {
        return toolbarView.viewWithTag(10) as! STTextView
    }
    
}