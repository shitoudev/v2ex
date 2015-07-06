//
//  PostViewController.swift
//  v2ex
//
//  Created by zhenwen on 6/16/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class PostViewController: BaseViewController {
    
    var tableView: PostTableView!
    
    var dataType: PostType!
    var target: String!
    
    //args: NSDictionary
    func allocWithRouterParams(args: NSDictionary?) -> PostViewController {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("postViewController") as! PostViewController
        viewController.hidesBottomBarWhenPushed = true
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView = PostTableView(frame: view.bounds, style: .Plain)
        tableView.dataType = dataType
        tableView.target = target
        self.view = tableView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.deselectRow()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}