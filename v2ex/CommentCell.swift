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

//let usernameRegularExpression = NSRegularExpression(pattern: "@[^\"?][^.](\\S*)", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
let usernameRegularExpression = NSRegularExpression(pattern: "@[^.\"?]((?!\\.)\\w){2,}", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
//let httpRegularExpression = NSRegularExpression(pattern: "[a-zA-z]+://[^\\s)）\"]*", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
let httpRegularExpression = NSRegularExpression(pattern: "(?:https?|ftp|file)://[\\w.+?&#/%=~\\-|$]*", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!

//let httpRegularExpression = NSRegularExpression(pattern: "(?<![.*\">])\\b(?:(?:https?|ftp|file)://|[a-z]\\.)[-A-Z0-9+&#/%=~_|$?!:,.]*[A-Z0-9+&#/%=~_|$]", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!

let linkFont = CTFontCreateWithName(UIFont.systemFontOfSize(14).fontName, UIFont.systemFontOfSize(14).pointSize, nil)

class CommentCell: UITableViewCell {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var contentLabel: TTTAttributedLabel!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var isButtonAddTarget = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        avatarButton.layer.cornerRadius = 5
        avatarButton.layer.masksToBounds = true
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.font = UIFont.systemFontOfSize(12)
        usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        var linkAttributes = Dictionary<String, AnyObject>()
        linkAttributes[kCTForegroundColorAttributeName as! String] = UIColor.colorWithHexString(kLinkColor).CGColor
        contentLabel.linkAttributes = linkAttributes
        contentLabel.extendsLinkTouchArea = false
    }
    
    func updateCell(comment: CommentModel) -> Void {
        avatarButton.kf_setImageWithURL(NSURL(string: comment.member.avatar_large)!, forState: .Normal, placeholderImage: nil)
        usernameButton.setTitle(comment.member.username, forState: .Normal)
        timeLabel.text = comment.getSmartTime()
        
//        contentLabel.text = comment.content
//        return
        
        if comment.linkMatched {
            contentLabel.setText(comment.content, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString) -> NSMutableAttributedString! in
                if comment.linkRange?.count > 0 {
                    for range in comment.linkRange! {
                        addLinkAttributed(mutableAttributedString, range: range)
                    }
                }
                return mutableAttributedString
            })
        } else {
            var linkRange = [NSRange]()
            
            contentLabel.setText(comment.content, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString) -> NSMutableAttributedString! in
                
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
//                    println("result = \(result), flags = \(flags)")
                })
                
                return mutableAttributedString
            })
            
            comment.linkRange = linkRange
            comment.linkMatched = true
        }
        
        if comment.linkRange?.count > 0 {
            for range in comment.linkRange! {
                let linkStr = (comment.content as NSString).substringWithRange(range)
                contentLabel.addLinkToURL(NSURL(string: linkStr), withRange: range)
            }
        }
    }
    
    func addAttributed(attrStr: NSMutableAttributedString, range: NSRange) -> NSMutableAttributedString {
        
        attrStr.removeAttribute(kCTForegroundColorAttributeName as! String, range: range)
        attrStr.addAttribute(kCTForegroundColorAttributeName as! String, value: UIColor.colorWithHexString(kLinkColor).CGColor, range: range)
        
        return attrStr
    }
}