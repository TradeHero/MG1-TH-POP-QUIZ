//
//  THUser.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Argo

struct User: JSONDecodable, DebugPrintable {
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
}

class THUser: NSObject, NSCoding {

    let userId: Int!
    var firstName: String = ""
    var lastName: String = ""
    var displayName: String!
    var pictureURL: String!

    private let kPictureURLKey = "Picture URL"
    private let kUserIdKey = "User ID"
    private let kFirstNameKey = "First Name"
    private let kLastNameKey = "Last Name"
    private let kDispNameKey = "Display Name"

    //    public let gamePortfolioID
    //    public lazy var gamePortfolio: GamePortfolio = GamePortfolio()

    init(profileDTO: [String:AnyObject]) {
        if let id: AnyObject = profileDTO["id"] {
            self.userId = id as Int
        }

        if let fn: AnyObject = profileDTO["firstName"] {
            self.firstName = fn as String
        }

        if let ln: AnyObject = profileDTO["lastName"] {
            self.lastName = ln as String
        }

        if let pic: AnyObject = profileDTO["picture"] {
            self.pictureURL = pic as String
        }

        if let dn: AnyObject = profileDTO["displayName"] {
            self.displayName = dn as String
        }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        if let fbpicurl = pictureURL {
            aCoder.encodeObject(fbpicurl, forKey: kPictureURLKey)
        }

        aCoder.encodeObject(firstName, forKey: kFirstNameKey)


        aCoder.encodeObject(lastName, forKey: kLastNameKey)


        if let n = displayName {
            aCoder.encodeObject(n, forKey: kDispNameKey)
        }

        if let uID = userId {
            aCoder.encodeInteger(uID, forKey: kUserIdKey)
        }

    }

    required init(coder aDecoder: NSCoder) {
        super.init()
        self.userId = aDecoder.decodeIntegerForKey(kUserIdKey)
        self.pictureURL = aDecoder.decodeObjectForKey(kPictureURLKey) as? String
        self.firstName = aDecoder.decodeObjectForKey(kFirstNameKey) as String
        self.lastName = aDecoder.decodeObjectForKey(kLastNameKey) as String
        self.displayName = aDecoder.decodeObjectForKey(kDispNameKey) as? String
    }

    init(userId: Int, pictureURL: String!, firstName: String!, lastName: String!, displayName: String) {
        self.userId = userId
        self.pictureURL = pictureURL
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName
    }
}

extension THUser: Printable {
    override var description: String {
        return "{\nTHUser\n======\nUser ID: \(self.userId)\nDisplay name: \(self.displayName)\nFirst name: \(self.firstName)\nLast name: \(self.lastName)\nProfile picture URL: \(self.pictureURL)\n}\n"
    }
}