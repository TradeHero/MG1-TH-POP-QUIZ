//
//  UserFriendDTO.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 11/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import Argo

struct UserFriend: Decodable, CustomDebugStringConvertible, Equatable, DictionaryRepresentation {
    let name: String
    let thUserId: Int
    let fbId: String
    let fbPicUrl: String
    let alreadyInvited: Bool
    
    var isTHUser: Bool {
        return thUserId != 0
    }
    
    static func decode(j: JSON) -> Decoded<UserFriend> {
        return self.create
                <^> j <| "name"
                <*> j <| "thUserId"
                <*> j <| "fbId"
                <*> j <| "fbPicUrl"
                <*> j <| "alreadyInvited"
    }

    static func create(name: String)(thUserId: Int)(fbId: String)(fbPicUrl: String)(alreadyInvited: Bool) -> UserFriend {
        return UserFriend(name: name, thUserId:thUserId, fbId: fbId, fbPicUrl: fbPicUrl, alreadyInvited: alreadyInvited)
    }

    var debugDescription: String {
        var d = "{\n"
        d += "Facebook ID: \(fbId)\n"
        d += "Image URL: \(fbPicUrl)\n"
        d += "Name: \(name)\n"
        d += "TradeHero User ID: \(thUserId)\n"
        d += "}\n"
        return d
    }

    var dictionaryRepresentation: [String:AnyObject] {
        return ["name": name, "thUserId": thUserId, "fbId": fbId, "fbPicUrl": fbPicUrl, "alreadyInvited": NSNumber(bool: alreadyInvited)];
    }
}

func ==(lhs: UserFriend, rhs: UserFriend) -> Bool {
    return lhs.name == rhs.name &&
            lhs.thUserId == rhs.thUserId &&
            lhs.fbId == rhs.fbId &&
            lhs.fbPicUrl == rhs.fbPicUrl &&
            lhs.alreadyInvited == rhs.alreadyInvited;
}