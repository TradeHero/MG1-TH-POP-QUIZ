//
//  THUserFriend.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/13/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

final class THUserFriend: NSObject, NSCoding {

    private let kFacebookIDKey = "FacebookID"
    private let kFacebookPictureURLKey = "FacebookPictureURL"
    private let kNameKey = "Name"
    private let kUserIdKey = "UserID"
    private let kAlreadyInvitedKey = "AlreadyInvited"

    var facebookID: Int!
    var facebookPictureURL: String!
    var name: String!
    var userID: Int! = 0
    var alreadyInvited: Bool = false

    lazy var isTHUser: Bool = {
        return self.userID != 0
    }()

    init(friendDTO: [String:AnyObject]) {
        self.facebookID = 0
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

        if let invited: AnyObject = friendDTO["alreadyInvited"] {
            self.alreadyInvited = invited as Bool
        }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        if let fbID = facebookID {
            aCoder.encodeInteger(fbID, forKey: kFacebookIDKey)
        }

        if let fbpicurl = facebookPictureURL {
            aCoder.encodeObject(fbpicurl, forKey: kFacebookPictureURLKey)
        }

        if let n = name {
            aCoder.encodeObject(n, forKey: kNameKey)
        }

        if let uID = userID {
            aCoder.encodeInteger(uID, forKey: kUserIdKey)
        }

        aCoder.encodeBool(alreadyInvited, forKey: kAlreadyInvitedKey)

    }

    init(coder aDecoder: NSCoder) {
        super.init()
        self.facebookID = aDecoder.decodeIntegerForKey(kFacebookIDKey)
        self.facebookPictureURL = aDecoder.decodeObjectForKey(kFacebookPictureURLKey) as? String
        self.name = aDecoder.decodeObjectForKey(kNameKey) as? String
        self.userID = aDecoder.decodeIntegerForKey(kUserIdKey)
    }
}

extension THUserFriend: Printable {
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
