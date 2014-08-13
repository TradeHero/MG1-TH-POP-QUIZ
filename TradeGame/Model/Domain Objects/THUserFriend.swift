//
//  THUserFriend.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class THUserFriend: NSObject {
    var facebookID: Int!
    var facebookPictureURL: String!
    var name: String!
    var userID: Int!
    
    init(friendDTO:[String: AnyObject]) {
        if let fbID: AnyObject = friendDTO["fbId"] {
            self.facebookID = (fbID as String).toInt()
        }
        
        if let fbPictureURL: AnyObject = friendDTO["fbPicUrl"] {
            self.facebookPictureURL = fbPictureURL as String
        }
        
        if let n: AnyObject = friendDTO["name"] {
            self.name = n as String
        }
        
        if let uID: AnyObject = friendDTO["thUserId"] {
            self.userID = uID as Int
        }
    }
}

extension THUserFriend : Printable {
    override var description: String {
        var d = "{\n"
            d += "Facebook ID: \(facebookID)\n"
            d += "Image URL: \(facebookPictureURL)\n"
            d += "Name: \(name)\n"
            d += "TradeHero User ID: \(userID)\n"
            d += "}\n"
            return d
    }
}
