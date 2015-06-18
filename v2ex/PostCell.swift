//
//  PostCell.swift
//  v2ex
//
//  Created by zhenwen on 6/16/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nodeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.picView.layer.cornerRadius = 5
        self.picView.layer.masksToBounds = true
        self.nodeLabel.textColor = UIColor.grayColor()
        self.usernameLabel.font = UIFont.fontAwesomeOfSize(12)
        self.timeLabel.textAlignment = NSTextAlignment.Center
        self.timeLabel.textColor = UIColor.grayColor()
        self.timeLabel.font = UIFont.fontAwesomeOfSize(12)
        self.usernameLabel.textColor = UIColor.grayColor()
        self.timeLabel.hidden = true
        self.repliesLabel.font = self.usernameLabel.font
        self.repliesLabel.textColor = self.usernameLabel.textColor
    }
    
    func updateCell(post: PostModel) -> Void {
        picView.kf_setImageWithURL(NSURL(string: post.avatar)!, placeholderImage: nil)
        titleLabel.text = post.title
        nodeLabel.text = "[\(post.node)]"
        usernameLabel.text = String.fontAwesomeIconWithName(.User)+"  \(post.username)"
        repliesLabel.text = String.fontAwesomeIconWithName(.Comment)+" \(post.replies)"
        
        if post.node.isEmpty {
            //            self.nodeLabel.hidden = true
            nodeLabel.font = UIFont.fontAwesomeOfSize(12)
            nodeLabel.text = String.fontAwesomeIconWithName(.User)+"  \(post.username)"
            repliesLabel.hidden = true
            usernameLabel.text = String.fontAwesomeIconWithName(.Comment)+" \(post.replies)"
        }
        //        self.timeLabel.text = article.getSmartTime()
    }
    
}