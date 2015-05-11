//
//  ArticleModel.swift
//  v2ex
//
//  Created by zhenwen on 5/2/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum TopicType: Int {
    case Hot
    case Latest
}

class ArticleModel: JSONAble {
    var aid: Int
    var title: String
    var url: String, content: String, created: Int
    var member: MemberModel, node: NodeModel
    
    init(fromDictionary dictionary: NSDictionary) {
        self.aid = dictionary["id"] as! Int
        self.url = dictionary["url"] as! String //!.stringValue
        self.content = dictionary["content"] as! String //!.stringValue
        self.title = dictionary["title"] as! String //!.stringValue
        self.created = dictionary["created"] as! Int
        
        self.member = MemberModel(fromDictionary: dictionary["member"] as! NSDictionary)
        self.node = NodeModel(fromDictionary: dictionary["node"] as! NSDictionary)
    }
    
    func getSmartTime() -> String {
        return String.smartDate(Double(self.created))
    }
    
    
    override class func fromJSON(json:[String: AnyObject]) -> JSONAble {
//        let json = JSON(json)
        return ArticleModel(fromDictionary: json)
    }
    
    static func getArticleList(topicType:TopicType, completionHandler:(obj: NSArray, NSError?)->Void) {
        
        var url = "https://www.v2ex.com/api/topics/"
        switch topicType {
        case .Hot:
            url += "hot.json"
        case .Latest:
            url += "latest.json"
        }

        var result = [ArticleModel]()
        Alamofire.request(.GET, url).responseJSON(options: .AllowFragments) { (_, _, jsonObject, error) -> Void in
            
            if error == nil {
                let json = JSON(jsonObject!).arrayValue
                
                for item in json {
                    var article = ArticleModel(fromDictionary: item.dictionaryObject!)
                    result.append(article)
                }
                
                completionHandler(obj: result, nil)
            }else{
                completionHandler(obj: [], error)
            }
            
        }
        
    }
    
    
    
}

