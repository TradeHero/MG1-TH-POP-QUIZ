//
//  THUser.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import Argo
import Runes

struct User: JSONDecodable, DebugPrintable, Equatable, DictionaryRepresentation {
    let userId: Int
    let firstName: String
    let lastName: String
    let displayName: String
    let pictureURL: String?
    
    static func decode(j: JSONValue) -> User? {
        return self.create
            <^> j <| "id"
            <*> j <|? "firstName"
            <*> j <|? "lastName"
            <*> j <| "displayName"
            <*> j <|? "picture"
    }
    
    static func create(id: Int)(firstName: String?)(lastName: String?)(displayName: String)(picture: String?) -> User {
        return User(userId: id, firstName: firstName ?? "", lastName: lastName ?? "", displayName: displayName, pictureURL: picture)
    }
    
    var debugDescription: String {
        return "{\nTHUser\n======\nUser ID: \(self.userId)\nDisplay name: \(self.displayName)\nFirst name: \(self.firstName)\nLast name: \(self.lastName)\nProfile picture URL: \(self.pictureURL)\n}\n"
    }
    
    var dictionaryRepresentation: [String: AnyObject] {
        return ["id" : userId, "firstName": firstName, "lastName": lastName, "displayName": displayName, "picture" : pictureURL ?? NSNull()];
    }
}

func ==(lhs: User, rhs: User) -> Bool{
    return lhs.userId == rhs.userId &&
        lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.displayName == rhs.displayName &&
        lhs.pictureURL == rhs.pictureURL;
}