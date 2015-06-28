//
//  STTextView.swift
//  v2ex
//
//  Created by zhenwen on 6/17/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import UIKit

public class STTextView: UITextView {
    
    var placeHolder: NSString! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var placeHolderTextColor: UIColor! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.configureTextView()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureTextView()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.configureTextView()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if count(self.text) == 0 && self.placeHolder != nil {
            self.placeHolderTextColor.set()
            
            self.placeHolder.drawInRect(CGRectInset(rect, 7.0, 6.0), withAttributes: self.placeholderTextAttributes())
        }
    }
    
    func configureTextView() -> Void {

        let cornerRadius: CGFloat = 5.0
        
        self.scrollEnabled = true
        self.scrollsToTop = false
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.cornerRadius = cornerRadius
        self.scrollIndicatorInsets = UIEdgeInsetsMake(cornerRadius, 0.0, cornerRadius, 0.0);
        
        self.textContainerInset = UIEdgeInsetsMake(3.0, 2.0, 3.0, 2.0);
        self.contentInset = UIEdgeInsetsMake(3.0, 0.0, 3.0, 0.0);
        
        self.backgroundColor = UIColor.whiteColor()
        self.font = UIFont.systemFontOfSize(13)
        self.placeHolder = "添加评论..."
        self.placeHolderTextColor = UIColor.lightGrayColor()
        
        self.addTextViewNotificationObservers()
        
    }
    
    func placeholderTextAttributes() -> [NSObject : AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        paragraphStyle.alignment = self.textAlignment;
        
        let attr = [NSFontAttributeName:self.font, NSForegroundColorAttributeName: placeHolderTextColor, NSParagraphStyleAttributeName: paragraphStyle]
        
        return attr
    }
    
    func addTextViewNotificationObservers() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveTextViewNotification:", name: UITextViewTextDidChangeNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveTextViewNotification:", name: UITextViewTextDidBeginEditingNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveTextViewNotification:", name: UITextViewTextDidEndEditingNotification, object: self)
    }
    
    func removeTextViewNotificationObservers() -> Void {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidChangeNotification, object: self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidBeginEditingNotification, object: self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidEndEditingNotification, object: self)
    }
    
    func didReceiveTextViewNotification(notification: NSNotification) {
        self.setNeedsDisplay()
    }
    
    // MARK: Lifetime
    
    deinit {
        removeTextViewNotificationObservers()
    }
    
}
