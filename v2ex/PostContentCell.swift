//
//  PostContentCell.swift
//  v2ex
//
//  Created by zhenwen on 7/2/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import v2exKit
import TTTAttributedLabel

class PostContentCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: TTTAttributedLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var avatarButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        separatorInset = UIEdgeInsetsZero
        titleLabel.font = kTitleFont

        avatarButton.layer.cornerRadius = 5
        avatarButton.layer.masksToBounds = true
        
        timeLabel.font = UIFont.systemFontOfSize(12)
        timeLabel.textColor = UIColor.grayColor()
        
        contentLabel.font = UIFont.systemFontOfSize(14)
        var linkAttributes = Dictionary<String, AnyObject>()
        linkAttributes[kCTForegroundColorAttributeName as! String] = UIColor.colorWithHexString(kLinkColor).CGColor
        contentLabel.linkAttributes = linkAttributes
        contentLabel.extendsLinkTouchArea = false
        contentLabel.font = kContentFont
    }
    
    func updateCell(postDetail: PostDetailModel) -> Void {
        
        titleLabel.text = postDetail.title
        usernameButton.setTitle(postDetail.member.username, forState: UIControlState.Normal)
        usernameButton.setTitleColor(UIColor.colorWithHexString(kLinkColor), forState: .Normal)
        avatarButton.kf_setImageWithURL(NSURL(string: postDetail.member.avatar_large)!, forState: .Normal, placeholderImage: nil)
        timeLabel.text = postDetail.getSmartTime()

        
        var linkRange = [NSRange]()
        contentLabel.setText(postDetail.content, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString) -> NSMutableAttributedString! in
            
            let stringRange = NSMakeRange(0, mutableAttributedString.length)
            // username
            usernameRegularExpression.enumerateMatchesInString(mutableAttributedString.string, options: NSMatchingOptions.ReportCompletion, range: stringRange, usingBlock: { (result, flags, stop) -> Void in
                
                if result != nil {
                    addLinkAttributed(mutableAttributedString, range: result.range)
                    linkRange.append(result.range)
                }
            })
            // http link
            httpRegularExpression.enumerateMatchesInString(mutableAttributedString.string, options: NSMatchingOptions.ReportCompletion, range: stringRange, usingBlock: { (result, flags, stop) -> Void in
                
                if result != nil {
                    addLinkAttributed(mutableAttributedString, range: result.range)
                    linkRange.append(result.range)
                }
            })
            
            return mutableAttributedString
        })
        
        if linkRange.count > 0 {
            for range in linkRange {
                let linkStr = (postDetail.content as NSString).substringWithRange(range)
                contentLabel.addLinkToURL(NSURL(string: linkStr), withRange: range)
            }
        }
    }
}
