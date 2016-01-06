//
//  PostModel.swift
//  v2ex
//
//  Created by zhenwen on 6/5/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Kanna

public enum PostType: Int {
    case Api
    case Node
    case Navi
    case User
}

public class PostModel: NSObject {

    public var postId: Int, replies: Int
    public var title: String, node: String, latestReplyTime: String
    public var member: MemberModel
    
    init(fromDictionary dictionary: NSDictionary) {
        
        self.postId = dictionary["postId"] as! Int
        self.replies = dictionary["replies"] as! Int
        self.title = dictionary["title"] as! String
        self.node = dictionary["node"] as! String
        self.latestReplyTime = dictionary["latestReplyTime"] as! String
        self.member = MemberModel(fromDictionary: dictionary["member"] as! NSDictionary)
    }
    /**
    获取主题
    
    :param: postType          主题类型
    :param: target            主题类型目标
    :param: completionHandler
    */
    public static func getPostList(postType:PostType, target:String, completionHandler:(obj: [PostModel], NSError?) -> Void) {

        if postType == .Api {
            PostModel.getLatestPosts({ (obj, errer) -> Void in
                completionHandler(obj: obj, errer)
            })
            return
        } else if postType == .Navi {
            let url = APIManage.Router.Navi + target
            var result = [PostModel]()
            let mgr = APIManage.sharedManager //Alamofire.Manager(configuration: cfg)
            mgr.request(.GET, url).responseString(completionHandler: { (response) -> Void in
            
                if response.result.isSuccess {
                    result = self.getPostsFromHtmlResponse(response.result.value!)
                    if target == "hot" {
                        // 保存3条数据，供 today extension 使用
                        self.saveDataForTodayExtension(result)
                    }
                    
                    completionHandler(obj: result, nil)
                } else {
                    let err = NSError(domain: APIManage.domain, code: 202, userInfo: [NSLocalizedDescriptionKey:"数据获取失败"])
                    completionHandler(obj: [], err)
                }
            })
            
        } else if postType == .Node || postType == .User {
            
            let url = (postType == .Node) ?  (APIManage.Router.Node + target) : (APIManage.Router.Member + target + "/topics")
            var result = [PostModel]()
            let mgr = APIManage.sharedManager //Alamofire.Manager(configuration: cfg)
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
        
    }
    
    /**
    获取最新主题
    
    :param: completionHandler
    */
    public static func getLatestPosts(completionHandler:(obj: [PostModel], NSError?) -> Void) {
        var result = [PostModel]()
        Alamofire.request(.GET, APIManage.Router.ApiLatest).responseJSON(options: .AllowFragments) { (response) -> Void in
            
            if response.result.isSuccess {
                let json = JSON(response.result.value!).arrayValue
                
                for item in json {
                    let itemObj = item.dictionaryObject!

                    let postId = itemObj["id"] as! Int
                    let avatar = itemObj["member"]!["avatar_large"] as! String
                    let title = itemObj["title"] as! String
                    let node = itemObj["node"]!["title"] as! String
                    let username = itemObj["member"]!["username"] as! String
                    let latestReplyTime = ""
                    let replies = itemObj["replies"] as! Int
                    let post = ["postId":postId, "replies":replies, "avatar":avatar, "title":title, "node":node, "username":username, "latestReplyTime":latestReplyTime, "member":["username":username, "avatar_large":avatar]] as NSDictionary
                    let postModel = PostModel(fromDictionary: post)
                    result.append(postModel)
                }
                
                completionHandler(obj: result, nil)
            }else{
                let err = NSError(domain: APIManage.domain, code: 202, userInfo: [NSLocalizedDescriptionKey:"数据获取失败"])
                completionHandler(obj: [], err)
            }
            
        }
    }
    
    /**
    获取用户创建的主题
    
    :param: username
    :param: completionHandler
    */
    public static func getUserPosts(username: String, completionHandler:(obj: [PostModel], NSError?) -> Void) {
        let url = APIManage.Router.Member + username
        var result = [PostModel]()
        let mgr = APIManage.sharedManager //Alamofire.Manager(configuration: cfg)
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
    public static func getPostsFromHtmlResponse(respStr: String) -> [PostModel] {
        var result = [PostModel]()
        
        guard let doc = HTML(html: respStr, encoding: NSUTF8StringEncoding) else {
            return result
        }
        
        for oneNode in doc.body!.css("table") {
            var postId = 0, avatar = "", title = "", node = "", username = "", latestReplyTime = "", replies = 0
            if let titleObj = oneNode.at_css("span[class='item_title']"), titleNode = titleObj.at_css("a"), titleText = titleNode.text {
                title = titleText
                let href = titleNode["href"]!
                let components = href.componentsSeparatedByString("/")
                if let componentsId = components.last?.componentsSeparatedByString("#") {
                    if let first = componentsId.first {
                        postId = (first as NSString).integerValue
                    }
                }
                
                // avatar
                if let avatarNode = oneNode.at_css("img[class='avatar']") {
                    avatar = avatarNode["src"]!
                }
                // node
                if let nodeObj = oneNode.at_css("a[class='node']"), nodeText = nodeObj.text {
                    node = nodeText
                }
                // username
                if let strongObj =  oneNode.at_css("strong"), usernameNode = strongObj.at_css("a"), usernameText = usernameNode.text {
                    username = usernameText
                }
                // replies
                if let repliesNode = oneNode.at_css("a[class='count_livid']"), repliesText = repliesNode.text {
                    replies = (repliesText as NSString).integerValue
                }
                let post = ["postId":postId, "replies":replies, "title":title, "node":node, "latestReplyTime":latestReplyTime, "member":["username":username, "avatar_large":avatar]] as NSDictionary
                //                    println("post = \(post)")
                let postModel = PostModel(fromDictionary: post)
                result.append(postModel)
            }
        }
        
        return result
    }
    
    static func saveDataForTodayExtension (post: [PostModel]) -> Void {
        // 保存3条数据，供 today extension 使用
        var dataSouce = [NSDictionary]()
        for (idx, val) in post.enumerate() {
            if idx == 3 {
                break
            }
            dataSouce.append(["id":val.postId, "title":val.title])
        }
        
        //TODO: 这里会有内存泄露
        let userDefaults = NSUserDefaults(suiteName: kAppGroupIdentifier)
        userDefaults?.setObject(dataSouce, forKey: kAppSharedDefaultsTodayExtensionDataKey)
        userDefaults?.synchronize()
    }
}