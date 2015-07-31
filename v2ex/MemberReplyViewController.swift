//
//  MemberReplyViewController.swift
//  v2ex
//
//  Created by zhenwen on 7/13/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class MemberReplyViewController: UITableViewController {
    
    var username: String!
    var dataSouce: [MemberReplyModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary?) -> MemberReplyViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("memberReplyViewController") as! MemberReplyViewController
        viewController.hidesBottomBarWhenPushed = true

        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let footerView = UIView.new()
        footerView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = footerView

        reloadTableViewData(isPull: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MemberReplyCell = tableView.dequeueReusableCellWithIdentifier("memberReplyCellId") as! MemberReplyCell
        let replyModel = dataSouce[indexPath.row]
        cell.updateCell(replyModel)
        
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let replyModel = dataSouce[indexPath.row]
        let viewController = PostDetailViewController().allocWithRouterParams(nil)
        viewController.postId = replyModel.post_id
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func reloadTableViewData(#isPull: Bool) {
        MemberReplyModel.getMemberReplies(username, completionHandler: { (obj, error) -> Void in
            if error == nil {
                self.dataSouce = obj
            } else {
                
            }
        })
    }
}