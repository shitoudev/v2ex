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
import v2exKit
import Kanna

class MemberReplyModel: NSObject {
    
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
        mgr.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (req, resp, str) -> Void in
            
            if str.isSuccess {
                result = self.getMemberRepliesFromHtmlResponse(str.value!)
                completionHandler(obj: result, nil)
            } else {
                let err = NSError(domain: APIManage.domain, code: 202, userInfo: [NSLocalizedDescriptionKey:"数据获取失败"])
                completionHandler(obj: [], err)
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
        
        guard let doc = HTML(html: respStr, encoding: NSUTF8StringEncoding) else {
            return result
        }
        
        let body = doc.body!
        let divs = body.css("div[class='dock_area']")
        if divs.count > 0 {
            // 读取评论内容
            var contents = [String]()
            for contentNode in body.css("div[class='reply_content']") {
                let rawContent = contentNode.text!
                let content = htmlRegularExpression.stringByReplacingMatchesInString(rawContent, options: .Anchored, range: NSMakeRange(0, rawContent.characters.count), withTemplate: "")
                contents.append(content)
            }
            
            for (index, value) in divs.enumerate() {
                var postId = 0, postTitle = "", dateTime = ""
                if let postNode = value.at_css("span[class='gray']"), aNode = postNode.at_css("a") {
                    postTitle = aNode.text!
                    
                    let href = aNode["href"]!
                    let components = href.componentsSeparatedByString("/")
                    if let componentsId = components.last?.componentsSeparatedByString("#") {
                        if let first = componentsId.first {
                            postId = (first as NSString).integerValue
                        }
                    }
                }
                if let timeNode = value.at_css("span[class='fade']"), timeText = timeNode.text {
                    dateTime = timeText
                }
                // 评论内容
                let content = contents[index]
                
                let reply = ["post_id":postId, "post_title":postTitle, "reply_content":content, "date_time":dateTime]
                let replyModel = MemberReplyModel(fromDictionary: reply)
                result.append(replyModel)
            }

        }
        return result
    }
}
