//
//  MemberReplyCell.swift
//  v2ex
//
//  Created by zhenwen on 7/13/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class MemberReplyCell: UITableViewCell {

    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var replyContentLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    var markLayer: CAShapeLayer!
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        cellSelected(highlighted, animated: animated)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        cellSelected(selected, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .None
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsZero
        postTitleLabel.backgroundColor = UIColor.colorWithHexString("#edf3f5")
        postTitleLabel.textColor = UIColor.colorWithHexString("#778087")
        dateTimeLabel.backgroundColor = postTitleLabel.backgroundColor
        dateTimeLabel.textColor = UIColor.grayColor()
        
        let x = CGFloat(20), width = CGFloat(10), height = CGFloat(6), y = postTitleLabel.height-height
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(CGFloat(width/2), 0))
        path.addLineToPoint(CGPointMake(width, height))
        path.addLineToPoint(CGPointMake(0, height))
        path.closePath()
        
        self.markLayer = CAShapeLayer()
        markLayer.path = path.CGPath
        markLayer.fillColor = UIColor.whiteColor().CGColor
        markLayer.position = CGPointMake(x, postTitleLabel.height-height)
        markLayer.actions = ["fillColor":NSNull()]
        contentView.layer.addSublayer(markLayer)
    }
    
    func updateCell(replyModel: MemberReplyModel) -> Void {
        postTitleLabel.text = "    " + replyModel.post_title
        replyContentLabel.text = replyModel.reply_content
        dateTimeLabel.text = replyModel.date_time
    }
    
    func cellSelected(selected: Bool, animated: Bool) {
        markLayer.actions = animated ? nil : ["fillColor":NSNull()]
        if animated {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.changeColor(selected)
            })
        } else {
            changeColor(selected)
        }
    }
    
    func changeColor(selected: Bool) {
        contentView.backgroundColor = selected ? UIColor.colorWithHexString("#d9d9d9") : UIColor.whiteColor()
        markLayer.fillColor = contentView.backgroundColor?.CGColor
    }

}