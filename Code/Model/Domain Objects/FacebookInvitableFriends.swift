//
//  FacebookInvitableFriends.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 12/2/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import Argo

struct FacebookInvitableFriend :JSONDecodable, DebugPrintable{
    let inviteToken : String
    
    let name : String
    
    let pictureUrl: String?
    
    static func create(id: String)(name: String)(pictureUrl:String?) -> FacebookInvitableFriend{
        return FacebookInvitableFriend(inviteToken: id, name: name, pictureUrl: pictureUrl)
    }
    
    static func decode(j: JSONValue) -> FacebookInvitableFriend? {
        return FacebookInvitableFriend.create
            <^> j <| "id"
            <*> j <| "name"
            <*> j <|? ["picture", "data", "url"]
    }
    
    var debugDescription: String {
        get {
            return "Invite token: \(inviteToken)\nName: \(name)\nPictureUrl: \(pictureUrl!)"
        }
    }

}