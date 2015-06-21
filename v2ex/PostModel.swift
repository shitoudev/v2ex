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

enum PostType: Int {
    case Api
    case Node
    case Navi
}

class PostModel: JSONAble {

    var postId: Int, replies: Int
    var avatar: String, title: String, node: String, username: String, latestReplyTime: String
    
    init(fromDictionary dictionary: NSDictionary) {
        
        self.postId = dictionary["postId"] as! Int
        self.replies = dictionary["replies"] as! Int
        self.avatar = dictionary["avatar"] as! String
        self.title = dictionary["title"] as! String
        self.node = dictionary["node"] as! String
        self.username = dictionary["username"] as! String
        self.latestReplyTime = dictionary["latestReplyTime"] as! String
        
        if avatar.hasPrefix("//") {
            self.avatar = "http:" + avatar
        }
    }
    /**
    获取主题
    
    :param: postType          主题类型
    :param: target            主题类型目标
    :param: completionHandler
    */
    static func getPostList(postType:PostType, target:String, completionHandler:(obj: NSArray, NSError?) -> Void) {

        if postType == .Api {
            PostModel.getLatestPosts({ (obj, errer) -> Void in
                completionHandler(obj: obj, errer)
            })
            return
        } else if postType == .Navi {
            let url = APIManage.Router.Navi + target
            var result = [PostModel]()
            let mgr = APIManage.sharedManager //Alamofire.Manager(configuration: cfg)
            mgr.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (req, resp, str, error) -> Void in
                
                if error == nil {
                    result = self.getPostsFromHtmlResponse(str!)
                    completionHandler(obj: result, nil)
                } else {
                    completionHandler(obj: [], error)
                }
            })
            
        } else if postType == .Node {
            
            let url = APIManage.Router.Node + target
            var result = [PostModel]()
            let mgr = APIManage.sharedManager //Alamofire.Manager(configuration: cfg)
            mgr.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (req, resp, str, error) -> Void in
                
                if error == nil {
                    result = self.getPostsFromHtmlResponse(str!)
                    completionHandler(obj: result, nil)
                } else {
                    completionHandler(obj: [], error)
                }
            })
            
        }
        
    }
    
    /**
    获取最新主题
    
    :param: completionHandler
    */
    static func getLatestPosts(completionHandler:(obj: NSArray, NSError?) -> Void) {
        var result = [PostModel]()
        Alamofire.request(.GET, APIManage.Router.ApiLatest).responseJSON(options: .AllowFragments) { (_, _, jsonObject, error) -> Void in
            
            if error == nil {
                let json = JSON(jsonObject!).arrayValue
                
                for item in json {
                    let itemObj = item.dictionaryObject!

                    let postId = itemObj["id"] as! Int
                    let avatar = itemObj["member"]!["avatar_large"] as! String
                    let title = itemObj["title"] as! String
                    let node = itemObj["node"]!["title"] as! String
                    let username = itemObj["member"]!["username"] as! String
                    let latestReplyTime = ""
                    let replies = itemObj["replies"] as! Int
                    let post = ["postId":postId, "replies":replies, "avatar":avatar, "title":title, "node":node, "username":username, "latestReplyTime":latestReplyTime] as NSDictionary
                    var postModel = PostModel(fromDictionary: post)
                    result.append(postModel)
                }
                
                completionHandler(obj: result, nil)
            }else{
                completionHandler(obj: [], error)
            }
            
        }
    }
    
    /**
    获取用户创建的主题
    
    :param: username
    :param: completionHandler
    */
    static func getUserPosts(username: String, completionHandler:(obj: NSArray, NSError?) -> Void) {
        let url = APIManage.Router.Member + username
        var result = [PostModel]()
        let mgr = APIManage.sharedManager //Alamofire.Manager(configuration: cfg)
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
    static func getPostsFromHtmlResponse(respStr: String) -> [PostModel] {
        var result = [PostModel]()
        var err: NSError?
        let parser = HTMLParser(html: respStr, error: &err)
        
        let bodyNode = parser.body
        if let tables = bodyNode?.findChildTags("table") {
            if !tables.isEmpty {
                for oneNode: HTMLNode in tables {
                    var postId = 0, avatar = "", title = "", node = "", username = "", latestReplyTime = "", replies = 0
                    // id & title
                    if let titleObj: HTMLNode = oneNode.findChildTagAttr("span", attrName: "class", attrValue: "item_title") {
                        if let titleNode = titleObj.findChildTag("a") {
                            title = titleNode.contents
                            let href = titleNode.getAttributeNamed("href")
                            let components = href.componentsSeparatedByString("/")
                            let componentsId = components.last?.componentsSeparatedByString("#")
                            postId = (componentsId?.first)!.toInt()!
                        }
                        // avatar
                        if let avatarNode: HTMLNode = oneNode.findChildTagAttr("img", attrName: "class", attrValue: "avatar") {
                            avatar = avatarNode.getAttributeNamed("src")
                        }
                        // node
                        if let nodeObj: HTMLNode = oneNode.findChildTagAttr("a", attrName: "class", attrValue: "node") {
                            node = nodeObj.contents
                        }
                        // username
                        if let strongObj: HTMLNode =  oneNode.findChildTag("strong") {
                            if let usernameNode = strongObj.findChildTag("a") {
                                username = usernameNode.contents
                            }
                        }
                        // replies
                        if let repliesNode: HTMLNode = oneNode.findChildTagAttr("a", attrName: "class", attrValue: "count_livid") {
                            replies = repliesNode.contents.toInt()!
                        }
                        let post = ["postId":postId, "replies":replies, "avatar":avatar, "title":title, "node":node, "username":username, "latestReplyTime":latestReplyTime] as NSDictionary
                        //                    println("post = \(post)")
                        var postModel = PostModel(fromDictionary: post)
                        result.append(postModel)
                    }
                }
                
            }
        }
        
        return result
    }
}