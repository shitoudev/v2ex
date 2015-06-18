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
    
    var comment_id: Int, thanks: Int, created: Int, last_modified: Int
    var content: String, content_rendered: String
    var member: MemberModel
    
    init(fromDictionary dictionary: NSDictionary) {
        self.comment_id = dictionary["id"] as! Int
        self.thanks = dictionary["thanks"] as! Int
        self.created = dictionary["created"] as! Int
        self.last_modified = dictionary["last_modified"] as! Int

        self.content = dictionary["content"] as! String //!.stringValue
        self.content_rendered = dictionary["content_rendered"] as! String
        
        self.member = MemberModel(fromDictionary: dictionary["member"] as! NSDictionary)
    }
    
    func getSmartTime() -> String {
        return String.smartDate(Double(self.created))
    }
    
    static func getComments(postId:Int, completionHandler:(obj: NSArray, NSError?)->Void) {
        
        let url = APIManage.Router.ApiComment + String(postId)
        
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
    
}
