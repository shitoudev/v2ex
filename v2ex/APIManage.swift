//
//  APIManage.swift
//  v2ex
//
//  Created by zhenwen on 5/24/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Alamofire

class APIManage: Manager {
    
//    enum Router: URLRequestConvertible {
    
    static let domain = "v2ex.com"
    static let baseURLString = "http://www." + APIManage.domain + "/"

    struct Router {
        
        static var ApiLatest: String {
            return APIManage.baseURLString + "api/topics/latest.json"
        }
        
        static var ApiComment: String {
            return APIManage.baseURLString + "api/replies/show.json?topic_id="
        }
        
        static var ApiMember: String {
            return APIManage.baseURLString + "api/members/show.json"
        }
        
        static var ApiTopic: String {
            return APIManage.baseURLString + "api/topics/show.json?id="
        }
        
        static var Navi: String {
            return APIManage.baseURLString + "?tab="
        }
        
        static var Node: String {
            return APIManage.baseURLString + "go/"
        }
        
        static var Signin: String {
            return APIManage.baseURLString + "signin"
        }
        
        static var Post: String {
            return APIManage.baseURLString + "t/"
        }
        
        static var Member: String {
            return APIManage.baseURLString + "member/"
        }
        
        static var Notification: String {
            return APIManage.baseURLString + "notifications"
        }
        
    }

    internal static let sharedManager: APIManage = {

        let cookiesStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPCookieStorage = cookiesStorage
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
        configuration.HTTPAdditionalHeaders = APIManage.defaultHTTPHeaders
       
        return APIManage(configuration: configuration)
    }()
    
    /**
    获取once
    
    :param: respStr 返回的 html string
    
    :returns: once string
    */
    static func getOnceStringFromHtmlResponse(respStr: String) -> String {
        var once = ""
        var err: NSError?
        let parser = HTMLParser(html: respStr, encoding: NSUTF8StringEncoding, option: CInt(HTML_PARSE_NOERROR.value | HTML_PARSE_RECOVER.value), error: &err)
        
        let bodyNode = parser.body
        if let onceNode = bodyNode?.findChildTagAttr("input", attrName: "name", attrValue: "once") {
            once = onceNode.getAttributeNamed("value")
        }
        
        return once
    }

}