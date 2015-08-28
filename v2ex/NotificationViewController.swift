//
//  NotificationViewController.swift
//  v2ex
//
//  Created by zhenwen on 8/19/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class NotificationViewController: UITableViewController {
    
    var dataSouce: [NotificationModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary?) -> NotificationViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("notificationViewController") as! NotificationViewController
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadTableViewData(#isPull: Bool) {
        NotificationModel.getUserNotifications { (obj, error) -> Void in
            if error == nil {
                self.dataSouce = obj
            }
        }
    }
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension NotificationViewController {
    // UITableViewDataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NotificationCell = tableView.dequeueReusableCellWithIdentifier("notificationCellId") as! NotificationCell
        let dataModel = dataSouce[indexPath.row]
        cell.updateCell(dataModel)
        
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count;
    }
    // UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dataModel = dataSouce[indexPath.row]
        let viewController = PostDetailViewController().allocWithRouterParams(nil)
        viewController.postId = dataModel.post_id
        navigationController?.pushViewController(viewController, animated: true)
    }
}
