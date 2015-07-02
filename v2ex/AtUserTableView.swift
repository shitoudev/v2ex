//
//  AtUserTableView.swift
//  v2ex
//
//  Created by zhenwen on 7/1/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

protocol AtUserTableViewDelegate {
    func didSelectedUser(user: MemberModel)
}

class AtUserTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var originData: [MemberModel]!
    var dataSouce: [MemberModel] = [MemberModel]() {
        didSet {
            self.reloadData()
        }
    }
    var searchText: String!
    var atDelegate: AtUserTableViewDelegate?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        self.dataSource = self
        self.delegate = self
        self.rowHeight = 44
        
        self.registerNib(UINib(nibName: "MemberCell", bundle: nil), forCellReuseIdentifier: "memberCellId")
        
        let footerView = UIView.new()
        footerView.backgroundColor = UIColor.clearColor()
        self.tableFooterView = footerView
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: MemberCell = tableView.dequeueReusableCellWithIdentifier("memberCellId") as! MemberCell
        
        let member = dataSouce[indexPath.row]
        cell.updateCell(member)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count;
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        atDelegate?.didSelectedUser(dataSouce[indexPath.row])
    }
    
    func searchMember() -> Bool {
        
        let namePredicate = NSPredicate(format: "username contains[c] %@", self.searchText)
        dataSouce = originData.filter({ (user: MemberModel) -> Bool in
            return namePredicate.evaluateWithObject(user)
        })
        
        return dataSouce.count > 0
        
    }
    
}
