//
//  LatestViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class LatestViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var hotTableView: UITableView!

    var indexPath: NSIndexPath?
    var refreshControl: UIRefreshControl!
    
    var hotArticleArr = [ArticleModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "最新"
        
        var footerView = UIView.new()
        footerView.backgroundColor = UIColor.clearColor()
        self.hotTableView.tableFooterView = footerView
        self.hotTableView.delegate = self
        self.hotTableView.dataSource = self
        
        self.hotTableView.registerNib(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        
        self.reloadTableViewData(isPull: false)
        
        self.refreshControl = UIRefreshControl(frame: self.hotTableView.bounds)
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.hotTableView.addSubview(self.refreshControl)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (indexPath != nil) {
            self.hotTableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        self.reloadTableViewData(isPull: true)
    }
    
    func reloadTableViewData(#isPull: Bool) {
        if !isPull {
            self.loadingView.startAnimating()
        }
        ArticleModel.getArticleList(.Latest, completionHandler: { (obj, error) -> Void in
            self.loadingView.stopAnimating()
            if error == nil {
                self.reloadView.hidden = true
                self.hotArticleArr.removeAll(keepCapacity: true)
                self.hotArticleArr.extend(obj as! Array)
                self.hotTableView.reloadData()
                
            }else{
                self.reloadView.hidden = false
            }
            
            if isPull {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    // MARK: reload data
    override func reloadViewTapped(sender: UIButton!) {
        self.reloadTableViewData(isPull: false)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ArticleCell = tableView.dequeueReusableCellWithIdentifier("ArticleCell") as! ArticleCell
        
        let article = hotArticleArr[indexPath.row]
        cell.updateCell(article)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hotArticleArr.count;
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexPath = indexPath
        let article = hotArticleArr[indexPath.row]
        var webViewController = WebViewController().allocWithRouterParams(["url":article.url])
        webViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56
    }

}