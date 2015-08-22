//
//  NotificationModel.swift
//  v2ex
//
//  Created by zhenwen on 8/10/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import v2exKit

let delFuncRegularExpression = NSRegularExpression(pattern: "[a-zA-z]+\\(([\\d]+),\\s*([\\d]+)\\)", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!

class NotificationModel: JSONAble {
    
    var content: String, title: String
    var n_id: Int, once_token: Int // 删除通知需要用到：$.post('/delete/notification/' + nId + '?once=' + token, function(data) { })
    var post_id: Int
    var member: MemberModel
    var linkRange: [NSRange]?, linkMatched = false, contentRegexed = false, apiData = true
    var smart_time: String?
    
    init(fromDictionary dictionary: NSDictionary) {
        
        self.title = dictionary["title"] as! String
        self.content = dictionary["content"] as! String //!.stringValue
        self.n_id = dictionary["n_id"] as! Int
        self.once_token = dictionary["once_token"] as! Int
        self.post_id = dictionary["post_id"] as! Int
        
        self.smart_time = dictionary["smart_time"] as? String

        self.member = MemberModel(fromDictionary: dictionary["member"] as! NSDictionary)
    }
    
    /**
    获取通知
    
    :param: completionHandler
    */
    static func getUserNotifications(completionHandler:(obj: [NotificationModel], NSError?) -> Void) {
        let url = APIManage.Router.Notification
        var result = [NotificationModel]()
        let mgr = APIManage.sharedManager
        mgr.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (req, resp, str, error) -> Void in
            
            if error == nil {
                result = self.getPostsFromHtmlResponse(str!)
                completionHandler(obj: result, nil)
            } else {
                completionHandler(obj: [], error)
            }
        })
    }
    
    /**
    获取
    
    :param: respStr 返回的 html string
    
    :returns: post 数组
    */
    static func getPostsFromHtmlResponse(respStr: String) -> [NotificationModel] {
        var result = [NotificationModel]()
        var err: NSError?
        let parser = HTMLParser(html: respStr, encoding: NSUTF8StringEncoding, option: CInt(HTML_PARSE_NOERROR.value | HTML_PARSE_RECOVER.value), error: &err)
        
        let bodyNode = parser.body
        if let tables = bodyNode?.findChildTags("table") where !tables.isEmpty {
            
            for oneNode: HTMLNode in tables {
                
                var title = "", content = "", smart_time = "", username = "", avatar = "", n_id = 0, once_token = 0, post_id = 0
                if let payloadNode: HTMLNode = oneNode.findChildTagAttr("div", attrName: "class", attrValue: "payload") {
                    // content
                    let rawContent = payloadNode.rawContents
                    content = htmlRegularExpression.stringByReplacingMatchesInString(rawContent, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(rawContent)), withTemplate: "")
                    // time
                    if let timeNode: HTMLNode = oneNode.findChildTagAttr("span", attrName: "class", attrValue: "snow") {
                        smart_time = timeNode.contents
                    }
                    // username & title & post_id
                    if let fadeNode: HTMLNode = oneNode.findChildTagAttr("span", attrName: "class", attrValue: "fade") {
                        if let nameNode: HTMLNode = fadeNode.findChildTag("strong") {
                            username = nameNode.contents
                        }
                        
                        let aNode = fadeNode.findChildTags("a")
                        if aNode.last != nil {
                            let alast = aNode.last!
                            title = alast.contents
                            
                            let href = alast.getAttributeNamed("href")
                            let components = href.componentsSeparatedByString("/")
                            if let componentsId = components.last?.componentsSeparatedByString("#") {
                                if let first = componentsId.first {
                                    post_id = first.toInt()!
                                }
                            }
                        }
                    }
                    // avatar
                    if let avatarNode: HTMLNode = oneNode.findChildTagAttr("img", attrName: "class", attrValue: "avatar") {
                        avatar = avatarNode.getAttributeNamed("src")
                    }
                    // n_id & once_token
                    if let delNode: HTMLNode = oneNode.findChildTagAttr("a", attrName: "class", attrValue: "node") {
                        let onclickValue = delNode.getAttributeNamed("onclick")
                        let range = NSMakeRange(0, count(onclickValue))
                        let idString = delFuncRegularExpression.stringByReplacingMatchesInString(onclickValue, options: .allZeros, range: range, withTemplate: "$1-$2")
                        let idArr = idString.componentsSeparatedByString("-")
                        if (idArr.first != nil) {
                            n_id = idArr.first!.toInt()!
                        }
                        if (idArr.last != nil) {
                            once_token = idArr.last!.toInt()!
                        }
                    }
                    
                    let post = ["title":title, "content":content, "smart_time":smart_time, "n_id":n_id, "once_token":once_token, "post_id":post_id, "member":["username":username, "avatar_large":avatar]] as NSDictionary
                    var model = NotificationModel(fromDictionary: post)
                    result.append(model)
                }
            }
            
        }
        
        return result
    }
}
