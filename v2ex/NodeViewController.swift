//
//  NodeViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import v2exKit

class NodeViewController: BaseViewController{
    
    
    @IBOutlet weak var tableView: UITableView!

    var dataSouce: [AnyObject]! {
        didSet {
            self.tableView.reloadData()
        }
    }
    var indexPath: NSIndexPath!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "节点"
        
        self.dataSouce = []
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 48
        tableView.tableFooterView = defaultTableFooterView
        
        self.refreshControl = UIRefreshControl(frame: self.tableView.bounds)
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(self.refreshControl)
        
        reloadTableViewData(isPull: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userStatusChanged(_:)), name: v2exUserLogoutSuccessNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userStatusChanged(_:)), name: v2exUserLoginSuccessNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if indexPath != nil {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: v2exUserLogoutSuccessNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: v2exUserLoginSuccessNotification, object: nil)
    }
    
    func refresh() {
        self.reloadTableViewData(isPull: true)
    }
    
    func reloadTableViewData(isPull pull: Bool) {
        
        NodeModel.getNodeList({ (obj, error) -> Void in
            if error == nil {
                self.dataSouce = obj
            }
            
            if pull {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    /// 
    func getNodesBySection(section: Int) -> [NodeModel] {
        return dataSouce[section]["node"] as! [NodeModel]
    }
    
    // MARK: NSNotification
    
    func userStatusChanged(notification: NSNotification) {
        reloadTableViewData(isPull: false)
    }
    
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension NodeViewController: UITableViewDelegate, UITableViewDataSource {
    // UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("nodeCellId")!
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let node = getNodesBySection(indexPath.section)[indexPath.row]
        cell.textLabel?.text = node.title
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSouce.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNodesBySection(section).count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSouce[section]["title"] as? String
    }
    
    // UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexPath = indexPath
        
        let node = getNodesBySection(indexPath.section)[indexPath.row]
        let type = dataSouce[indexPath.section]["type"] as! NSNumber

        let postViewController = PostViewController().allocWithRouterParams(nil)
        postViewController.title = node.title
        postViewController.dataType = PostType(rawValue: type.integerValue)
        postViewController.target = node.name
        self.navigationController?.pushViewController(postViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

}