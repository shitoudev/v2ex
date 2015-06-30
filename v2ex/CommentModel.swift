//
//  CommentModel.swift
//  v2ex
//
//  Created by zhenwen on 6/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CommentModel: JSONAble {
    
    var comment_id: Int
    var content: String
    var member: MemberModel
    var linkRange: [NSRange]?, linkMatched = false, contentRegexed = false, apiData = true
    var smart_time: String?, content_rendered: String?, created: Int?, last_modified: Int?, thanks: Int?
    
    init(fromDictionary dictionary: NSDictionary) {
        self.comment_id = dictionary["id"] as! Int
        self.content = dictionary["content"] as! String //!.stringValue
        
        self.content_rendered = dictionary["content_rendered"] as? String
        self.smart_time = dictionary["smart_time"] as? String
        self.created = dictionary["created"] as? Int
        self.last_modified = dictionary["last_modified"] as? Int
        self.thanks = dictionary["thanks"] as? Int

        self.member = MemberModel(fromDictionary: dictionary["member"] as! NSDictionary)
    }
    
    func getContent() -> String {
        if !contentRegexed {
            self.content = content.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
            self.contentRegexed = true
        }
        return content
    }
    
    func getSmartTime() -> String {
        if smart_time != nil {
            return smart_time!
        } else {
            return created == nil ? "" : String.smartDate(Double(self.created!))
        }
    }
    
    /**
    通过接口获取评论
    
    :param: postId            主题ID
    :param: completionHandler 回调
    */
    static func getComments(postId:Int, salt: String, completionHandler:(obj: NSArray, NSError?)->Void) {
        
        let url = APIManage.Router.ApiComment + String(postId) + salt
        
        var result = [CommentModel]()
        Alamofire.request(.GET, url).responseJSON(options: .AllowFragments) { (_, _, jsonObject, error) -> Void in
            
            if error == nil {
                let json = JSON(jsonObject!).arrayValue
                
                for item in json {
                    var comment = CommentModel(fromDictionary: item.dictionaryObject!)
                    result.append(comment)
                }
                
                completionHandler(obj: result, nil)
            }else{
                completionHandler(obj: [], error)
            }
            
        }
        
    }
    
    /**
    通过网页获取评论
    
    :param: postId            主题ID
    :param: page              当前页数
    :param: completionHandler 回调
    */
    static func getCommentsFromHtml(postId: Int, page: Int, completionHandler:(obj: NSArray, NSError?)->Void) {
        let url = APIManage.Router.Post + String(postId) + "?p=\(page)"
        var result = [CommentModel]()
        let mgr = APIManage.sharedManager
        mgr.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (req, resp, str, error) -> Void in
            
            if error == nil {
                result = self.getCommentsFromHtmlResponse(str!)
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
    private static func getCommentsFromHtmlResponse(respStr: String) -> [CommentModel] {
        var result = [CommentModel]()
        var err: NSError?
        let parser = HTMLParser(html: respStr, error: &err)
        
        let bodyNode = parser.body
        if let divs = bodyNode?.findChildTagsAttr("div", attrName: "class", attrValue: "cell") {
            for div in divs {
                if let table = div.findChildTag("table") {
                    var comment_id = 0, avatar = "", content = "", username = "", smart_time = ""
                    let divId = div.getAttributeNamed("id")
                    if !divId.isEmpty {
                        // avatar
                        if let avatarNode: HTMLNode = table.findChildTagAttr("img", attrName: "class", attrValue: "avatar") {
                            avatar = avatarNode.getAttributeNamed("src")
                            // comment id
                            let divId = div.getAttributeNamed("id")
                            let components = divId.componentsSeparatedByString("_")
                            if let lastStr = components.last {
                                comment_id = lastStr.toInt()!
                            }
                            // username
                            if let usernameNode = table.findChildTagAttr("a", attrName: "class", attrValue: "dark") {
                                username = usernameNode.contents
                            }
                            // content
                            if let contentNode = table.findChildTagAttr("div", attrName: "class", attrValue: "reply_content") {
                                content = contentNode.rawContents
                            }
                            // smart time
                            if let timeNode = table.findChildTagAttr("span", attrName: "class", attrValue: "fade small") {
                                smart_time = timeNode.contents
                            }
                            let comment = ["id":comment_id, "content":content, "smart_time":smart_time, "member":["username":username, "avatar_large":avatar]]
                            var commentModel = CommentModel(fromDictionary: comment)
                            commentModel.apiData = false
                            result.append(commentModel)
                        }
                    }
                }
            }
        }
        
        return result
    }
    
}
