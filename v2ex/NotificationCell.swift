//
//  NotificationCell.swift
//  v2ex
//
//  Created by zhenwen on 8/19/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
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
        
        let x = CGFloat(20), width = CGFloat(10), height = CGFloat(6), y = postTitleLabel.height
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(width, 0))
        path.addLineToPoint(CGPointMake(CGFloat(width/2), height))
        path.closePath()
        
        self.markLayer = CAShapeLayer()
        markLayer.path = path.CGPath
        markLayer.fillColor = postTitleLabel.backgroundColor!.CGColor
        markLayer.position = CGPointMake(x, y)
        markLayer.actions = ["fillColor":NSNull()]
        contentView.layer.addSublayer(markLayer)
    }
    
    func updateCell(dataModel: NotificationModel) -> Void {
        contentLabel.text = dataModel.content
        dateTimeLabel.text = dataModel.smart_time
        let title = "    " + dataModel.member.username + " 在 " + dataModel.title + " 中提到了你" as NSString
        var attributedStr = NSMutableAttributedString(string: title as String)
        let range = title.rangeOfString(dataModel.member.username)
        attributedStr.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(12), range: range)
        postTitleLabel.attributedText = attributedStr
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
    }
    
}
