//
//  MemberReplyModel.swift
//  v2ex
//
//  Created by zhenwen on 7/17/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let htmlRegularExpression = NSRegularExpression(pattern: "<[^>]+>", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!

class MemberReplyModel: JSONAble {
    
    var post_title: String, reply_content: String, date_time: String
    var post_id: Int
    
    init(fromDictionary dictionary: NSDictionary) {
        self.post_id = dictionary["post_id"] as! Int
        self.post_title = dictionary["post_title"] as! String
        self.reply_content = dictionary["reply_content"] as! String
        self.date_time = dictionary["date_time"] as! String
    }
    
    static func getMemberReplies(username: String, completionHandler:(obj: [MemberReplyModel], NSError?)->Void) {
        let url = APIManage.Router.Member + username + "/replies"
        var result = [MemberReplyModel]()
        let mgr = APIManage.sharedManager
        mgr.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (req, resp, str, error) -> Void in
            
            if error == nil {
                result = self.getMemberRepliesFromHtmlResponse(str!)
                completionHandler(obj: result, nil)
            } else {
                completionHandler(obj: [], error)
            }
        })
    }
    
    /**
    解析html 返回评论
    
    :param: respStr html string
    
    :returns: post 数组
    */
    private static func getMemberRepliesFromHtmlResponse(respStr: String) -> [MemberReplyModel] {
        var result = [MemberReplyModel]()
        var err: NSError?
        let parser = HTMLParser(html: respStr, encoding: NSUTF8StringEncoding, option: CInt(HTML_PARSE_NOERROR.value | HTML_PARSE_RECOVER.value), error: &err)
        
        let bodyNode = parser.body
        if let divs = bodyNode?.findChildTagsAttr("div", attrName: "class", attrValue: "dock_area") {
            // 读取评论内容
            var contents = [String]()
            if let contentsNode = bodyNode?.findChildTagsAttr("div", attrName: "class", attrValue: "reply_content") {
                for contentNode in contentsNode {
                    let rawContent = contentNode.rawContents
                    let content = htmlRegularExpression.stringByReplacingMatchesInString(rawContent, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(rawContent)), withTemplate: "")
                    contents.append(content)
                }
            }
            
            for (index, value) in enumerate(divs) {
                var postId = 0, postTitle = "", dateTime = ""
                // 主题ID、标题、时间
                if let postNode = value.findChildTagAttr("span", attrName: "class", attrValue: "gray") {
                    if let aNode = postNode.findChildTag("a") {
                        postTitle = aNode.contents
                        
                        let href = aNode.getAttributeNamed("href")
                        let components = href.componentsSeparatedByString("/")
                        if let componentsId = components.last?.componentsSeparatedByString("#") {
                            if let first = componentsId.first {
                                postId = first.toInt()!
                            }
                        }
                    }
                    if let timeNode = value.findChildTagAttr("span", attrName: "class", attrValue: "fade") {
                        dateTime = timeNode.contents
                    }
                }
                
                // 评论内容
                let content = contents[index]
                
                let reply = ["post_id":postId, "post_title":postTitle, "reply_content":content, "date_time":dateTime]
                var replyModel = MemberReplyModel(fromDictionary: reply)
                result.append(replyModel)
            }
        }
        
        return result
    }
}
