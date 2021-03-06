//
//  CommentCell.swift
//  v2ex
//
//  Created by zhenwen on 6/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import v2exKit

let usernameRegularExpression = try! NSRegularExpression(pattern: "@[^.\"?]((?!\\.)\\w){2,}", options: NSRegularExpressionOptions.CaseInsensitive)
let httpRegularExpression = try!  NSRegularExpression(pattern: "(?:https?|ftp|file)://[\\w+?&#/%=~\\-|@$?!:,.]*", options: NSRegularExpressionOptions.CaseInsensitive)

//let httpRegularExpression = NSRegularExpression(pattern: "(?<![.*\">])\\b(?:(?:https?|ftp|file)://|[a-z]\\.)[-A-Z0-9+&#/%=~_|$?!:,.]*[A-Z0-9+&#/%=~_|$]", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!

class CommentCell: UITableViewCell {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var contentLabel: TTTAttributedLabel!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var isButtonAddTarget = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        separatorInset = UIEdgeInsetsZero
        selectionStyle = UITableViewCellSelectionStyle.None
        avatarButton.layer.cornerRadius = 5
        avatarButton.layer.masksToBounds = true
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.font = UIFont.systemFontOfSize(12)
        usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        usernameButton.setTitleColor(UIColor.colorWithHexString(kLinkColor), forState: .Normal)
        
        var linkAttributes = Dictionary<String, AnyObject>()
        linkAttributes[kCTForegroundColorAttributeName as String] = UIColor.colorWithHexString(kLinkColor).CGColor
        contentLabel.linkAttributes = linkAttributes
        contentLabel.extendsLinkTouchArea = false
        contentLabel.font = kContentFont
    }
    
    func updateCell(comment: CommentModel) -> Void {
        avatarButton.kf_setImageWithURL(NSURL(string: comment.member.avatar_large)!, forState: .Normal, placeholderImage: nil)
        usernameButton.setTitle(comment.member.username, forState: .Normal)
        timeLabel.text = comment.getSmartTime()
        
        let content = comment.apiData ? comment.content : comment.getContent()
        if comment.linkMatched {
            contentLabel.setText(content, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString) -> NSMutableAttributedString! in
                if comment.linkRange?.count > 0 {
                    for range in comment.linkRange! {
                        addLinkAttributed(mutableAttributedString, range: range)
                    }
                }
                return mutableAttributedString
            })
        } else {
            var linkRange = [NSRange]()
            
            contentLabel.setText(content, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString) -> NSMutableAttributedString! in
                
                let stringRange = NSMakeRange(0, mutableAttributedString.length)
                // username
                usernameRegularExpression.enumerateMatchesInString(mutableAttributedString.string, options: NSMatchingOptions.ReportCompletion, range: stringRange, usingBlock: { (result, flags, stop) -> Void in

                    if let resultVal = result {
                        addLinkAttributed(mutableAttributedString, range: resultVal.range)
                        linkRange.append(resultVal.range)
                    }
                })
                // http link
                httpRegularExpression.enumerateMatchesInString(mutableAttributedString.string, options: NSMatchingOptions.ReportCompletion, range: stringRange, usingBlock: { (result, flags, stop) -> Void in
                    
                    if let resultVal = result {
                        addLinkAttributed(mutableAttributedString, range: resultVal.range)
                        linkRange.append(resultVal.range)
                    }
//                    println("result = \(result), flags = \(flags)")
                })
                
                return mutableAttributedString
            })
            
            comment.linkRange = linkRange
            comment.linkMatched = true
        }
        
        if comment.linkRange?.count > 0 {
            for range in comment.linkRange! {
                let linkStr = (content as NSString).substringWithRange(range)
                contentLabel.addLinkToURL(NSURL(string: linkStr), withRange: range)
            }
        }
    }
}
