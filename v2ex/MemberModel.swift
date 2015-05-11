//
//  MemberModel.swift
//  v2ex
//
//  Created by zhenwen on 5/8/15.
//  Copyright (c) 2015 zhenwen. All rights reserved.
//

import Foundation

class MemberModel {
    var username: String, uid: Int, avatar_large: String
    
    init(fromDictionary dictionary: NSDictionary) {
        self.uid = dictionary["id"] as! Int
        self.username = dictionary["username"] as! String
        self.avatar_large = dictionary["avatar_large"] as! String
    }
}
