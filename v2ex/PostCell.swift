//
//  PostCell.swift
//  v2ex
//
//  Created by zhenwen on 6/16/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import v2exKit
import SnapKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nodeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var picViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        separatorInset = UIEdgeInsetsZero
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
        picViewWidthConstraint.constant = 40
        if post.member.avatar_large.isEmpty {
            picViewWidthConstraint.constant = 0.1
            picView.image = nil
        } else {
            picView.kf_setImageWithURL(NSURL(string: post.member.avatar_large)!, placeholderImage: nil)
        }
        titleLabel.text = post.title
        nodeLabel.text = "[\(post.node)]"
        usernameLabel.text = String.fontAwesomeIconWithName(.User)+"  \(post.member.username)"
        repliesLabel.text = String.fontAwesomeIconWithName(.Comment)+" \(post.replies)"
        
        if post.node.isEmpty {
            nodeLabel.font = UIFont.fontAwesomeOfSize(12)
            nodeLabel.text = String.fontAwesomeIconWithName(.User)+"  \(post.member.username)"
            repliesLabel.hidden = true
            usernameLabel.text = String.fontAwesomeIconWithName(.Comment)+" \(post.replies)"
        }
    }
    
}