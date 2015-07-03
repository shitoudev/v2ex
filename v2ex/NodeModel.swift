//
//  NodeModel.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation

class NodeModel {
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
    
    static func getNodeList(completionHandler:(obj: NSArray, NSError?)->Void) {
        
        let url = APIManage.baseURLString
        
        var result = [AnyObject]()

        let mgr = APIManage.sharedManager
        mgr.request(.GET, url, parameters: nil).responseString(encoding: nil, completionHandler: { (req, resp, respStr, error) -> Void in
            
            if error == nil {
                
                var err: NSError?
                let parser = HTMLParser(html: respStr!, encoding: NSUTF8StringEncoding, option: CInt(HTML_PARSE_NOERROR.value | HTML_PARSE_RECOVER.value), error: &err)
                
                let bodyNode = parser.body
                
                // parsing navi
                if let aNavi = bodyNode?.findChildTagsAttr("a", attrName: "class", attrValue: "tab") {
                    var data = ["title":"导航", "node":[], "type":NSNumber(integer: 2)]
                    var nodeArr = [NodeModel]()
                    for aNode: HTMLNode in aNavi {
                        let title = aNode.contents
                        let href = aNode.getAttributeNamed("href").componentsSeparatedByString("=")
                        let name = href.last!
                        
                        let nodeInfo = ["name":name, "title":title] as NSDictionary
                        let nodeModel = NodeModel(fromDictionary: nodeInfo)
                        nodeArr.append(nodeModel)
                    }
                    data["node"] = nodeArr
                    result.append(data)
                }
                
                // parsing node
                if let div = bodyNode?.findChildTagsAttr("div", attrName: "class", attrValue: "cell") {
                    var titleArr = [String]()
                    for divNode: HTMLNode in div {
                        if let table: HTMLNode = divNode.findChildTag("table") {
                            let td = table.findChildTags("td")
                            if !td.isEmpty {
                                if let span = td.first?.findChildTagAttr("span", attrName: "class", attrValue: "fade") {
                                    if let a = td.last?.findChildTags("a") {
                                        var canAdd = true
                                        if titleArr.count > 0 {
                                            for titleStr in titleArr {
                                                if titleStr == span.contents {
                                                    canAdd = false
                                                }
                                            }
                                        }
                                        if canAdd {
                                            titleArr.append(span.contents)
                                            var data = ["title":span.contents, "node":[], "type":NSNumber(integer: 1)]
                                            var nodeArr = [NodeModel]()
                                            for aNode in a {
                                                let title = aNode.contents
                                                let href = aNode.getAttributeNamed("href").componentsSeparatedByString("/")
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
                    }
                }
            }
            completionHandler(obj: result, error)

        })
        
    }
}
