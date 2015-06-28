//
//  PostCell.swift
//  v2ex
//
//  Created by zhenwen on 6/16/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import v2exKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nodeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        picView.layer.cornerRadius = 5
        picView.layer.masksToBounds = true
        nodeLabel.textColor = UIColor.grayColor()
        usernameLabel.font = UIFont.fontAwesomeOfSize(12)
        timeLabel.textAlignment = NSTextAlignment.Center
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.font = UIFont.fontAwesomeOfSize(12)
        usernameLabel.textColor = UIColor.grayColor()
        timeLabel.hidden = true
        repliesLabel.font = usernameLabel.font
        repliesLabel.textColor = usernameLabel.textColor
        titleLabel.font = kTitleFont
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