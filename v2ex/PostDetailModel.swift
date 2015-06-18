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

class PostDetailModel: JSONAble {

    var aid: Int, replies: Int, created: Int, last_modified: Int, last_touched: Int
    var title: String, url: String, content: String, content_rendered: String
    var member: MemberModel, node: NodeModel
    
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
        
        Alamofire.request(.GET, url).responseJSON(options: .AllowFragments) { (_, _, jsonObject, error) -> Void in
            
            if error == nil {
                let json = JSON(jsonObject!).arrayValue
                let first = json.first?.dictionaryObject
                let data = PostDetailModel(fromDictionary: first!)
                
                completionHandler(detail: data, nil)
            }else{
                completionHandler(detail: nil, error)
            }
            
        }
        
    }
    
}