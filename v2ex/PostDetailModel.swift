//
//  PostDetailModel.swift
//  v2ex
//
//  Created by zhenwen on 6/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Kanna
import CoreSpotlight
import MobileCoreServices
import v2exKit

class PostDetailModel: NSObject {

    var aid: Int, replies: Int, created: Int, last_modified: Int, last_touched: Int
    var title: String, url: String, content: String, content_rendered: String
    var member: MemberModel, node: NodeModel
    var tags: [String]?
    
    init(fromDictionary dictionary: NSDictionary) {
        self.aid = dictionary["id"] as! Int
        self.url = dictionary["url"] as! String //!.stringValue
        self.content = dictionary["content"] as! String //!.stringValue
        self.title = dictionary["title"] as! String //!.stringValue
        self.created = dictionary["created"] as! Int
        self.last_modified = dictionary["last_modified"] as! Int
        self.last_touched = dictionary["last_touched"] as! Int
        self.replies = dictionary["replies"] as! Int
        self.content_rendered = dictionary["content_rendered"] as! String
        
        self.member = MemberModel(fromDictionary: dictionary["member"] as! NSDictionary)
        self.node = NodeModel(fromDictionary: dictionary["node"] as! NSDictionary)
    }
    
    func getSmartTime() -> String {
        return String.smartDate(Double(self.created))
    }
    
    static func getPostDetail(postId:Int, completionHandler:(detail: PostDetailModel?, NSError?)->Void) {
        
        let url = APIManage.Router.ApiTopic + String(postId)
        
        Alamofire.request(.GET, url).responseJSON(options: .AllowFragments) { (_, _, jsonObject) -> Void in
            
            if jsonObject.isSuccess {
                let json = JSON(jsonObject.value!).arrayValue
                let first = json.first?.dictionaryObject
                let data = PostDetailModel(fromDictionary: first!)
                completionHandler(detail: data, nil)
                // 索引文章
                if #available(iOS 9.0, *) {
                    PostDetailModel.getPostTags(postId, completionHandler: { (tags, error) -> Void in
                        if let tagArr = tags {
                            data.tags = tagArr
                            PostDetailModel.indexPost(data)
                        }
                    })
                }
            }else{
                let err = NSError(domain: APIManage.domain, code: 202, userInfo: [NSLocalizedDescriptionKey:"数据获取失败"])
                completionHandler(detail: nil, err)
            }
            
        }
    }
    
    static func getPostTags(postId: Int, completionHandler:(tags: [String]?, NSError?)->Void) {
        // 使用 APIManage 获取的数据中没有包含 tag 的数据，暂时不知道原因
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            do {
                let postURL = APIManage.Router.Post + "\(postId)"
                let html = try String(contentsOfURL: NSURL(string: postURL)!, encoding: NSUTF8StringEncoding)
                guard let doc = HTML(html: html, encoding: NSUTF8StringEncoding) else {
                    return
                }
                var tagArr = [String]()
                for aNode in doc.body!.css("a[class='tag']") {
                    if let text = aNode.text {
                        tagArr.append(text.trim())
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionHandler(tags: tagArr, nil)
                })
            } catch {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let err = NSError(domain: APIManage.domain, code: 202, userInfo: [NSLocalizedDescriptionKey:"数据获取失败"])
                    completionHandler(tags: nil, err)
                })
            }
        }
    }
    
    @available(iOS 9.0, *)
    static func indexPost(post: PostDetailModel) {
        var content = post.content
        if content.characters.count > 40 {
            content = content.substringToIndex(content.startIndex.advancedBy(40))
        }
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
        attributeSet.title = post.title
        attributeSet.contentDescription = content
        attributeSet.keywords = post.tags!
        let searchableItem = CSSearchableItem(uniqueIdentifier: String(format: kAppPostScheme, arguments: [post.aid]), domainIdentifier: "cc.shitoudev.v2ex.post", attributeSet: attributeSet)
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([searchableItem]) { (error) -> Void in
            if error != nil {
                print("failed with error:\(error)\n")
            } else {
                print("Indexed!\n")
            }
        }
    }
    
}