//
//  TodayViewController.swift
//  v2exTodayExtension
//
//  Created by zhenwen on 6/22/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import NotificationCenter
import v2exKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var tableView: UITableView!
    var dataSouce: NSArray! {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        
        let userDefaults = NSUserDefaults(suiteName: kAppGroupIdentifier)
        let data = userDefaults?.objectForKey(kAppSharedDefaultsTodayExtensionDataKey) as? NSArray
        self.dataSouce = data?.count > 0 ? data : []
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let height = Int(tableView.rowHeight) * dataSouce.count
        preferredContentSize = CGSize(width: view.width, height: CGFloat(height))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 15, right: 0)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        //TODO: 从网络获取数据

        completionHandler(NCUpdateResult.NewData)
    }
    
    func refresh() {
        self.reloadTableViewData(isPull: true)
    }
    
    func reloadTableViewData(isPull pull: Bool) {
        
    }
    
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    // UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("todayPostCellId")!
        
        let post = dataSouce[indexPath.row] as! NSDictionary
        cell.textLabel?.text = post["title"] as? String
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = UIFont.systemFontOfSize(14)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count;
    }
    
    // UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let post = dataSouce[indexPath.row] as! NSDictionary
        let postId = post["id"]! as! Int
        let url = String(format: kAppPostScheme, arguments: [postId])
        self.extensionContext?.openURL(NSURL(string: url)!, completionHandler: { (succ) -> Void in
            
        })
    }
}

