//
//  PostTableView.swift
//  v2ex
//
//  Created by zhenwen on 6/5/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import v2exKit

class PostTableView: UITableView {
    
    var dataType: PostType!
    var target: String! {
        didSet {
            self.reloadTableViewData(isPull: false)
        }
    }
    
    var dataSouce: [PostModel] = [] {
        didSet {
            self.reloadData()
        }
    }
    var indexPath: NSIndexPath!
    var refreshControl: UIRefreshControl!

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        dataSource = self
        delegate = self
        rowHeight = 56
        layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        registerNib(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "postCellId")
        tableFooterView = defaultTableFooterView
        
        self.refreshControl = UIRefreshControl(frame: self.bounds)
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.addSubview(self.refreshControl)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refresh() {
        self.reloadTableViewData(isPull: true)
    }
    
    func reloadTableViewData(isPull pull: Bool) {
        PostModel.getPostList(self.dataType, target: self.target, completionHandler: { (obj, error) -> Void in
            if error == nil {
                self.dataSouce = obj
            } else {
                
            }
            
            if pull {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    func deselectRow() -> Void {
        if (indexPath != nil) {
            deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension PostTableView: UITableViewDelegate, UITableViewDataSource {
    // UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PostCell = tableView.dequeueReusableCellWithIdentifier("postCellId") as! PostCell
        
        let post = dataSouce[indexPath.row]
        cell.updateCell(post)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count;
    }
    
    // UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexPath = indexPath
        if let vc = self.traverseResponderChainForUIViewController() where vc.isKindOfClass(UIViewController) {
            let post = self.dataSouce[indexPath.row]
            let viewController = PostDetailViewController().allocWithRouterParams(nil)
            viewController.postId = post.postId
            vc.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}