//
//  CommentCell.swift
//  v2ex
//
//  Created by zhenwen on 6/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var isButtonAddTarget = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.avatarButton.layer.cornerRadius = 5
        self.avatarButton.layer.masksToBounds = true
        self.timeLabel.textColor = UIColor.grayColor()
        self.timeLabel.font = UIFont.systemFontOfSize(12)
//        self.usernameButton.titleLabel?.textAlignment = NSTextAlignment.Left
        self.usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
    }
    
    func updateCell(comment: CommentModel) -> Void {
        avatarButton.kf_setImageWithURL(NSURL(string: comment.member.avatar_large)!, forState: .Normal, placeholderImage: nil)
        usernameButton.setTitle(comment.member.username, forState: .Normal)
        contentLabel.text = comment.content
        timeLabel.text = comment.getSmartTime()
    }
}
