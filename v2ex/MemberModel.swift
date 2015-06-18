//
//  MemberModel.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation
import SwiftyJSON

class MemberModel {
    var username: String, uid: Int, avatar_large: String
    var website: String?, twitter: String?, psn: String?, github: String?, btc: String?, location: String?, tagline: String?, bio: String?, created: Int?
    
    init(fromDictionary dictionary: NSDictionary) {
        self.uid = dictionary["id"] as! Int
        self.username = dictionary["username"] as! String
        self.avatar_large = dictionary["avatar_large"] as! String
        
        if self.avatar_large.hasPrefix("//") {
            self.avatar_large = "http:"+self.avatar_large
        }
        
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
                    let err = NSError(domain: APIManage.domain, code: 201, userInfo: nil)
                    completionHandler(obj: nil, err)
                }
                
            }else{
                completionHandler(obj: nil, error)
            }
        }
    }
}
