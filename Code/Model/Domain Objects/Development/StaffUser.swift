//
//  StaffUser.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 13/10/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

final class StaffUser: THUser {

    var funnyName: String
    
    init(profileDTO: [String : AnyObject], funnyName:String) {
        self.funnyName = funnyName
        super.init(profileDTO: profileDTO)
    }
    
    init(user:THUser, funnyName:String) {
        self.funnyName = funnyName
        super.init(userId: user.userId, pictureURL: user.pictureURL, firstName: user.firstName, lastName: user.lastName, displayName: user.displayName)
    }

    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(self.funnyName, forKey: "")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.funnyName = aDecoder.decodeObjectForKey("") as String
        super.init(coder: aDecoder)
    }
}
