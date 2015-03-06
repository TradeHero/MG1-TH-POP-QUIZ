//
//  StaffUser.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 13/10/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

struct StaffUser {

    let user: User
    
    var userId: Int {
        return user.userId
    }
    
    var firstName: String {
        return user.firstName
    }

    var lastName: String {
        return user.lastName
    }

    var displayName: String {
        return user.displayName
    }

    var pictureURL: String? {
        return user.pictureURL
    }

    
    var funnyName: String

    init(user: User, funnyName: String) {
        self.user = user
        self.funnyName = funnyName
    }


    var dictionaryRepresentation: [String: AnyObject] {
        return ["id" : userId, "firstName": firstName, "lastName": lastName, "displayName": displayName, "picture" : pictureURL ?? NSNull(), "funnyName" : funnyName];
    }
}
