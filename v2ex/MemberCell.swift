//
//  MemberCell.swift
//  v2ex
//
//  Created by zhenwen on 7/1/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import v2exKit

class MemberCell: UITableViewCell {
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        avatarButton.layer.cornerRadius = 5
        avatarButton.layer.masksToBounds = true
        avatarButton.enabled = false
        usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        usernameButton.setTitleColor(UIColor.colorWithHexString(kLinkColor), forState: .Disabled)
        usernameButton.enabled = false
    }
    
    func updateCell(member: MemberModel) -> Void {
        avatarButton.kf_setImageWithURL(NSURL(string: member.avatar_large)!, forState: .Disabled, placeholderImage: nil)
        usernameButton.setTitle(member.username, forState: .Disabled)
    }
    
}
