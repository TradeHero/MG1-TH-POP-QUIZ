//
//  THUser.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class THUser {
    
    public var userId: Int!
    public var displayName:String!
    public var firstName: String!
    public var lastName:String!
    public var fullName:String!
    public var pictureURL:String!
    public var gamePortfolio: GamePortfolio!
    
    public init(profileDTO:[String: AnyObject]){
        if let id: AnyObject? = profileDTO["id"] {
            self.userId = id as Int
        }
        
        if let dn: AnyObject? = profileDTO["displayName"] {
            self.displayName = dn as String
        }
        
        if let fn: AnyObject? = profileDTO["firstName"] {
            self.firstName = fn as String
        }
        
        if let ln: AnyObject? = profileDTO["lastName"] {
            self.lastName = ln as String
        }
        
        if let pic: AnyObject? = profileDTO["picture"] {
            self.pictureURL = pic as String
        }
        
        if self.firstName != nil && self.lastName != nil {
            self.fullName = "\(self.firstName) \(self.lastName)"
        }
    }
    
    /// dummy initializer 
    public init(userId:Int, _ dName:String, _ fName:String, _ lName: String, _ avatarURL:String, _ portfolio:GamePortfolio){
        self.userId = userId
        self.displayName = dName
        self.firstName = fName
        self.lastName = lName
        self.fullName = "\(self.firstName) \(self.lastName)"
        self.pictureURL = avatarURL
        self.gamePortfolio = portfolio
    }
}
