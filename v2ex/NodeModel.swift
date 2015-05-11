//
//  NodeModel.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation

class NodeModel {
    var node_id: Int, name: String, title: String, url: String, topics: Int, avatar_large: String
    var header: String?
    
    init(fromDictionary dictionary: NSDictionary) {
        self.node_id = dictionary["id"] as! Int
        self.name = dictionary["name"] as! String
        self.title = dictionary["title"] as! String
        self.url = dictionary["url"] as! String
        self.topics = dictionary["topics"] as! Int
        self.avatar_large = dictionary["avatar_large"] as! String
        
        if let header = dictionary["header"] as? String {
            self.header = header
        }
    }
    
    static func getNodeList(topicType:TopicType, completionHandler:(obj: NSArray)->Void) {
        
//        var url = "https://www.v2ex.com/api/topics/"
//        switch topicType {
//        case .Hot:
//            url += "hot.json"
//        case .Latest:
//            url += "latest.json"
//        }
//        
//        var result = [ArticleModel]()
//        Alamofire.request(.GET, url).responseJSON(options: .AllowFragments) { (_, _, jsonObject, error) -> Void in
//            
//            let json = JSON(jsonObject!).arrayValue
//            
//            for item in json {
//                var article = ArticleModel(fromDictionary: item.dictionaryObject!)
//                result.append(article)
//            }
//            
//            completionHandler(obj: result)
//        }
        
    }
}
