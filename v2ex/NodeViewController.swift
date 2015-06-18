//
//  NodeViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class NodeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!

    var dataSouce: NSArray! {
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
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 48
        
        let footerView = UIView.new()
        footerView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = footerView
        
        self.refreshControl = UIRefreshControl(frame: self.tableView.bounds)
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        self.reloadTableViewData(isPull: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("nodeCellId") as! UITableViewCell
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let arr = dataSouce[indexPath.section]["node"] as! NSArray
        let node = arr[indexPath.row] as! NodeModel
        cell.textLabel?.text = node.title
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSouce.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = dataSouce[section]["node"] as! NSArray
        return arr.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSouce[section]["title"] as? String
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexPath = indexPath
        
        let arr = dataSouce[indexPath.section]["node"] as! NSArray
        let node = arr[indexPath.row] as! NodeModel
        
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
    
    func refresh() {
        self.reloadTableViewData(isPull: true)
    }
    
    func reloadTableViewData(#isPull: Bool) {
        
        NodeModel.getNodeList({ (obj, error) -> Void in
            if error == nil {
                self.dataSouce = obj
            }
            
            if isPull {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
}