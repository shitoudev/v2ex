//
//  NodeViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

//class NodeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    @IBOutlet weak var hotTableView: UITableView!
//    
//    var nodeArr = [NodeModel]()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        self.title = "节点"
//        
//        var footerView = UIView.new()
//        footerView.backgroundColor = UIColor.clearColor()
//        self.hotTableView.tableFooterView = footerView
//        self.hotTableView.delegate = self
//        self.hotTableView.dataSource = self
//        
//        self.hotTableView.registerNib(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
//        ArticleModel.getArticleList(TopicType.Latest, completionHandler: { (obj) -> Void in
//            self.hotArticleArr.extend(obj as! Array)
//            self.hotTableView.reloadData()
//        })
//        
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    // MARK: UITableViewDataSource
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell: ArticleCell = tableView.dequeueReusableCellWithIdentifier("ArticleCell") as! ArticleCell
//        
//        let article = nodeArr[indexPath.row]
//        cell.updateCell(article)
//        
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.nodeArr.count;
//    }
//    
//    // MARK: UITableViewDelegate
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 56
//    }
//    
//}