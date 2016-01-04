//
//  APIManage.swift
//  v2ex
//
//  Created by zhenwen on 5/24/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Alamofire
import Kanna

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
        static var FindPwd: String {
            return APIManage.baseURLString + "forgot"
        }
        static var Captcha: String {
            return APIManage.baseURLString + "_captcha"
        }
        
    }
    
    /**
    Creates default values for the "Accept-Encoding", "Accept-Language" and "User-Agent" headers.
    */
    static let HTTPHeaders: [String: String] = {
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0,compress;q=0.5"
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage: String = {
            var components: [String] = []
            for (index, languageCode) in (NSLocale.preferredLanguages() as [String]).enumerate() {
                let q = 1.0 - (Double(index) * 0.1)
                components.append("\(languageCode);q=\(q)")
                if q <= 0.5 {
                    break
                }
            }
            
            return components.joinWithSeparator(",")
        }()
        
        // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
        let userAgent: String = {
            if let info = NSBundle.mainBundle().infoDictionary {
                let executable: AnyObject = info[kCFBundleExecutableKey as String] ?? "Unknown"
                let bundle: AnyObject = info[kCFBundleIdentifierKey as String] ?? "Unknown"
                let version: AnyObject = info[kCFBundleVersionKey as String] ?? "Unknown"
                let os: AnyObject = NSProcessInfo.processInfo().operatingSystemVersionString ?? "Unknown"
                
                var mutableUserAgent = NSMutableString(string: "\(executable)/\(bundle) (\(version); OS \(os))") as CFMutableString
                let transform = NSString(string: "Any-Latin; Latin-ASCII; [:^ASCII:] Remove") as CFString
                
                if CFStringTransform(mutableUserAgent, UnsafeMutablePointer<CFRange>(nil), transform, false) {
                    return mutableUserAgent as String
                }
            }
            
            return "Alamofire"
        }()
        
        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 9_0 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13A344"
        ]
    }()

    internal static let sharedManager: APIManage = {

        let cookiesStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPCookieStorage = cookiesStorage
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
        configuration.HTTPAdditionalHeaders = APIManage.HTTPHeaders //APIManage.defaultHTTPHeaders
       
        return APIManage(configuration: configuration)
    }()
    
    /**
    获取once
    
    :param: respStr 返回的 html string
    
    :returns: once string
    */
    static func getOnceStringFromHtmlResponse(respStr: String) -> String? {
        var once: String?
        guard let doc = HTML(html: respStr, encoding: NSUTF8StringEncoding) else {
            return once
        }
        if let onceNode = doc.body!.at_css("input[name='once']"), valueText = onceNode["value"] {
            once = valueText
        }
        return once
    }

}