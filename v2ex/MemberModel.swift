//
//  MemberModel.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import SwiftyJSON

private let dict = NSUserDefaults.standardUserDefaults().objectForKey(APIManage.domain) as? NSDictionary
private let sharedInstance = dict==nil ? MemberModel(fromDictionary: ["id":0, "username":"", "avatar_large":""]) : MemberModel(fromDictionary: dict!)

class MemberModel {
    var username: String, avatar_large: String
    var uid: Int?, website: String?, twitter: String?, psn: String?, github: String?, btc: String?, location: String?, tagline: String?, bio: String?, created: Int?
    
    init(fromDictionary dictionary: NSDictionary) {

        self.username = dictionary["username"] as! String
        self.avatar_large = dictionary["avatar_large"] as! String
        
        if self.avatar_large.hasPrefix("//") {
            self.avatar_large = "http:"+self.avatar_large
        }
        
        self.uid = dictionary["id"] as? Int
        self.website = dictionary["website"] as? String
        self.twitter = dictionary["twitter"] as? String
        self.psn = dictionary["psn"] as? String
        self.github = dictionary["github"] as? String
        self.btc = dictionary["btc"] as? String
        self.location = dictionary["location"] as? String
        self.tagline = dictionary["tagline"] as? String
        self.bio = dictionary["bio"] as? String
        self.created = dictionary["created"] as? Int

    }

    class var sharedMember: MemberModel {
        return sharedInstance
    }
    
    func isLogin() -> Bool {
        return (uid != 0) && !username.isEmpty
    }
    
    func saveUserData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(["id":uid!, "username":username, "avatar_large":avatar_large], forKey: APIManage.domain)
        defaults.synchronize()
    }
    
    func removeUserData() {
        self.uid = 0
        self.username = ""
        self.avatar_large = ""
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(APIManage.domain)
        defaults.synchronize()
        // remove cookie
        let cookiesStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = cookiesStorage.cookiesForURL(NSURL(string: APIManage.baseURLString)!) {
            for cookie in cookies {
                cookiesStorage.deleteCookie(cookie as! NSHTTPCookie)
            }
        }
    }
    
    static func getUserInfo(account: AnyObject, completionHandler: (obj: MemberModel?, NSError?)->Void) {
        
        var args = (account is Int) ? ["id":account] : ["username":account]
        
        APIManage.sharedManager.request(.GET, APIManage.Router.ApiMember, parameters: args).responseJSON(options: .AllowFragments) { (_, _, jsonObject, error) -> Void in
            if error == nil {
                let json = JSON(jsonObject!)
                let status = json["status"]
                if status == "found" {
                    let result = MemberModel(fromDictionary: json.dictionaryObject!)
                    completionHandler(obj: result, nil)
                }else{
                    let err = NSError(domain: APIManage.domain, code: 201, userInfo: [NSLocalizedDescriptionKey:"用户未找到"])
                    completionHandler(obj: nil, err)
                }
                
            }else{
                completionHandler(obj: nil, error)
            }
        }
    }
}
