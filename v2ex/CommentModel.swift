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
import Kanna

class CommentModel: NSObject {
    
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
    static func getComments(postId:Int, salt: String, completionHandler:(obj: [CommentModel], NSError?)->Void) {
        
        let url = APIManage.Router.ApiComment + String(postId) + salt
        
        var result = [CommentModel]()
        Alamofire.request(.GET, url).responseJSON(options: .AllowFragments) { (response) -> Void in
            
            if response.result.isSuccess {
                let json = JSON(response.result.value!).arrayValue
                for item in json {
                    let comment = CommentModel(fromDictionary: item.dictionaryObject!)
                    result.append(comment)
                }
                completionHandler(obj: result, nil)
            }else{
                let err = NSError(domain: APIManage.domain, code: 202, userInfo: [NSLocalizedDescriptionKey:"数据获取失败"])
                completionHandler(obj: [], err)
            }
            
        }
        
    }
    
    /**
    通过网页获取评论
    
    :param: postId            主题ID
    :param: page              当前页数
    :param: completionHandler 回调
    */
    static func getCommentsFromHtml(postId: Int, page: Int, completionHandler:(obj: [CommentModel], NSError?)->Void) {
        let url = APIManage.Router.Post + String(postId) + "?p=\(page)"
        var result = [CommentModel]()
        let mgr = APIManage.sharedManager
        mgr.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (response) -> Void in
            
            if response.result.isSuccess {
                result = self.getCommentsFromHtmlResponse(response.result.value!)
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
    private static func getCommentsFromHtmlResponse(respStr: String) -> [CommentModel] {
        var result = [CommentModel]()
        guard let doc = HTML(html: respStr, encoding: NSUTF8StringEncoding) else {
            return result
        }
        
        for div in doc.body!.css("div[class='cell']") {
            if let table = div.at_css("table"), divId = div["id"], avatarNode = table.at_css("img[class='avatar']") {
                var comment_id = 0, avatar = "", content = "", username = "", smart_time = ""
                avatar = avatarNode["src"]!
                // comment id
                let components = divId.componentsSeparatedByString("_")
                if let lastStr = components.last {
                    comment_id = (lastStr as NSString).integerValue
                }
                // username
                if let usernameNode = table.at_css("a[class='dark']"), nameText = usernameNode.text {
                    username = nameText
                }
                // content
                if let contentNode = table.at_css("div[class='reply_content']"), text = contentNode.text {
                    content = text
                }
                // smart time
                if let timeNode = table.at_css("span[class='fade small']"), timeText = timeNode.text {
                    smart_time = timeText
                }
                let comment = ["id":comment_id, "content":content, "smart_time":smart_time, "member":["username":username, "avatar_large":avatar]]
                let commentModel = CommentModel(fromDictionary: comment)
                commentModel.apiData = false
                result.append(commentModel)
            }
        }
        return result
    }
    
}
