//
//  NodeModel.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import Kanna

class NodeModel: NSObject {
    var name: String, title: String
    var node_id: Int?, header: String?, url: String?, topics: Int?, avatar_large: String?
    
    init(fromDictionary dictionary: NSDictionary) {
        self.node_id = dictionary["id"] as? Int
        self.name = dictionary["name"] as! String
        self.title = dictionary["title"] as! String
        self.url = dictionary["url"] as? String
        self.topics = dictionary["topics"] as? Int
        self.avatar_large = dictionary["avatar_large"] as? String
        
        if let header = dictionary["header"] as? String {
            self.header = header
        }
    }
    
    static func getNodeList(completionHandler:(obj: [AnyObject]?, NSError?)->Void) {
        
        let url = APIManage.baseURLString
        
        var result = [AnyObject]()

        let mgr = APIManage.sharedManager
        mgr.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (req, resp, respStr) -> Void in
            
            if respStr.isSuccess {
                guard let doc = HTML(html: respStr.value!, encoding: NSUTF8StringEncoding) else {
                    completionHandler(obj: result, nil)
                    return
                }
                
                let body = doc.body!
                
                // parsing navi
                var data = ["title":"导航", "node":[], "type":NSNumber(integer: 2)]
                var nodeArr = [NodeModel]()
                for aNode in body.css("a[class='tab']") {
                    let title = aNode.text!
                    let href = aNode["href"]!.componentsSeparatedByString("=")
                    let name = href.last!
                    
                    let nodeInfo = ["name":name, "title":title] as NSDictionary
                    let nodeModel = NodeModel(fromDictionary: nodeInfo)
                    nodeArr.append(nodeModel)
                }
                data["node"] = nodeArr
                if nodeArr.count > 0 {
                    result.append(data)
                }
                
                // parsing node
                var titleArr = [String]()
                for divNode in body.css("div[class='cell']") {
                    if let table = divNode.at_css("table"), tdFirst = table.css("td").first, span = tdFirst.at_css("span[class='fade']") {
                        let a = table.css("td").last!.css("a")
                        if a.count > 0 {
                            var canAdd = true
                            for titleStr in titleArr {
                                if titleStr == span.text {
                                    canAdd = false
                                }
                            }
                            if canAdd {
                                titleArr.append(span.text!)
                                var data = ["title":span.text!, "node":[], "type":NSNumber(integer: 1)]
                                var nodeArr = [NodeModel]()
                                for aNode in a {
                                    let title = aNode.text!
                                    let href = aNode["href"]!.componentsSeparatedByString("/")
                                    let name = href.last!
                                    let nodeInfo = ["name":name, "title":title] as NSDictionary
                                    
                                    let nodeModel = NodeModel(fromDictionary: nodeInfo)
                                    nodeArr.append(nodeModel)
                                }
                                data["node"] = nodeArr
                                result.append(data)
                            }
                        }
                    }
                }
            }
            completionHandler(obj: result, nil)

        })
        
    }
}
