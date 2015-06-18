//
//  HotViewController.swift
//  v2ex
//
//  Created by zhenwen on 5/2/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class HotViewController: BaseViewController {
    
    var tableView: PostTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "最热"
        
        self.tableView = PostTableView(frame: CGRect(x: 0, y: 64, width: self.view.width, height: self.view.height-64-49), style: UITableViewStyle.Plain)
        self.tableView.dataType = PostType.Navi
        self.tableView.target = "hot"
        self.view.addSubview(self.tableView)
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
