//
//  NotificationModel.swift
//  v2ex
//
//  Created by zhenwen on 8/10/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import v2exKit
import Kanna

let delFuncRegularExpression = try! NSRegularExpression(pattern: "[a-zA-z]+\\(([\\d]+),\\s*([\\d]+)\\)", options: NSRegularExpressionOptions.CaseInsensitive)

class NotificationModel: NSObject {
    
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
        mgr.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (response) -> Void in
            
            if response.result.isSuccess {
                result = self.getPostsFromHtmlResponse(response.result.value!)
                completionHandler(obj: result, nil)
            } else {
                let err = NSError(domain: APIManage.domain, code: 202, userInfo: [NSLocalizedDescriptionKey:"数据获取失败"])
                completionHandler(obj: [], err)
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
        guard let doc = HTML(html: respStr, encoding: NSUTF8StringEncoding) else {
            return result
        }
        
        for oneNode in doc.body!.css("table") {
            var title = "", content = "", smart_time = "", username = "", avatar = "", n_id = 0, once_token = 0, post_id = 0
            if let payloadNode = oneNode.at_css("div[class='payload']"), rawContent = payloadNode.text {
                // content
//                let rawContent = payloadNode.text
                content = htmlRegularExpression.stringByReplacingMatchesInString(rawContent, options: [NSMatchingOptions.Anchored], range: NSMakeRange(0, rawContent.characters.count), withTemplate: "")
                // time
                if let timeNode = oneNode.at_css("span[class='snow']"), timeText = timeNode.text {
                    smart_time = timeText
                }
                // username & title & post_id
                if let fadeNode = oneNode.at_css("span[class='fade']") {
                    if let nameNode = fadeNode.at_css("strong"), usernameText = nameNode.text {
                        username = usernameText
                    }
                    
                    if let alast = fadeNode.css("a").last, titleText = alast.text, href = alast["href"] {
                        title = titleText
                        
                        let components = href.componentsSeparatedByString("/")
                        if let componentsId = components.last?.componentsSeparatedByString("#"), first = componentsId.first {
                            post_id = (first as NSString).integerValue
                        }
                    }
                }
                // avatar
                if let avatarNode = oneNode.at_css("img[class='avatar']"), srcText = avatarNode["src"] {
                    avatar = srcText
                }
                // n_id & once_token
                if let delNode = oneNode.at_css("a[class='node']"), onclickValue = delNode["onclick"] {
                    let range = NSMakeRange(0, onclickValue.characters.count)
                    let idString = delFuncRegularExpression.stringByReplacingMatchesInString(onclickValue, options: .Anchored, range: range, withTemplate: "$1-$2")
                    let idArr = idString.componentsSeparatedByString("-")
                    if let first = idArr.first {
                        n_id = (first as NSString).integerValue
                    }
                    if let last = idArr.last {
                        once_token = (last as NSString).integerValue
                    }
                }
                
                let post = ["title":title, "content":content, "smart_time":smart_time, "n_id":n_id, "once_token":once_token, "post_id":post_id, "member":["username":username, "avatar_large":avatar]] as NSDictionary
                let model = NotificationModel(fromDictionary: post)
                result.append(model)
            }
        }
        return result
    }
}
