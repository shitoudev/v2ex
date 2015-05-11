//
//  ArticleCell.swift
//  v2ex
//
//  Created by zhenwen on 5/2/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nodeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.picView.layer.cornerRadius = 5
        self.picView.layer.masksToBounds = true
        self.nodeLabel.textColor = UIColor.grayColor()
//        self.usernameLabel.font = UIFont.boldSystemFontOfSize(12)
        self.usernameLabel.font = UIFont.fontAwesomeOfSize(12)
        self.timeLabel.textAlignment = NSTextAlignment.Center
        self.timeLabel.textColor = UIColor.grayColor()
    }
    
    func updateCell(article: ArticleModel) -> Void {
        self.picView.kf_setImageWithURL(NSURL(string: "http:"+article.member.avatar_large)!, placeholderImage: nil)
        self.titleLabel.text = article.title
        self.nodeLabel.text = "[\(article.node.title)]"
        self.usernameLabel.text = String.fontAwesomeIconWithName(.User)+"  \(article.member.username)"
        self.timeLabel.text = article.getSmartTime()
    }

}
