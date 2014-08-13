//
//  THUser.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class THUser {
    
    let userId: Int!
    var firstName: String!
    var lastName:String!
    var fullName:String!
    var pictureURL:String!
//    public let gamePortfolioID
//    public lazy var gamePortfolio: GamePortfolio = GamePortfolio()
    
    init(profileDTO:[String: AnyObject]){
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
            self.fullName = dn as String
        }
//        
//        if self.firstName != nil && self.lastName != nil {
//            self.fullName = "\(self.firstName) \(self.lastName)"
//        }
    }
    
    init(){
        
    }
}

extension THUser: Printable {
    var description: String {
        return "{\nDetails of THUser:\nUser ID: \(self.userId)\nFirst name: \(self.firstName)\nLast name: \(self.lastName)\nProfile picture URL: \(self.pictureURL)\n}\n"
    }
}