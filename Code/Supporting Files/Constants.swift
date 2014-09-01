//
//  Constants.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/6/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import Foundation

enum Mode: Int {
    case Dev
    case Prod
}

let TestFlightToken = "c1a29f46-4c93-4e9a-8b89-0ec297bf1622"

let kTHGamesServerMode = Mode.Dev

let kConstantPrefix = "TH"

// MARK:- connections

let kConnectionHTTPS = "https://"
let kConnectionHTTP = "http://"
let THAPIPath = "/api"

let THProdAPIHost = "www.tradehero.mobi"
let THProdAPIBaseURL = "\(kConnectionHTTPS)\(THProdAPIHost)\(THAPIPath)"

let THDevAPIHost = "th-paas-test-dev1.cloudapp.net"
let THDevAPIBaseURL = "\(kConnectionHTTP)\(THDevAPIHost)\(THAPIPath)"

let THServerAPIBaseURL = kTHGamesServerMode == Mode.Dev ? "\(THDevAPIBaseURL)" : "\(THProdAPIBaseURL)"

let THGameAPIBaseURL = "\(THServerAPIBaseURL)/games"


let THImagePathHost = "https://portalvhdskgrrf4wksb8vq.blob.core.windows.net/tradeherocompanypictures/"


let THAuthFacebookPrefix = "TH-Facebook"
// MARK:- keys

let kTHGameLoggedInKey = "\(kConstantPrefix)GameLoggedIn"
let kTHGameLoginIDKey = "\(kConstantPrefix)GameLoginID"

let kTHGameLoginPasswordKey = "\(kConstantPrefix)GameLoginPassword"
let kTHGameKeychainIdentifierKey = "\(kConstantPrefix)GameKeychainIdentifier"
let kTHGameKeychainBasicAccKey = "\(kConstantPrefix)GameKeychainBasicAcc"
let kTHGameKeychainFacebookAccKey = "\(kConstantPrefix)GameKeychainFacebookAcc"

//MARK:- notification keys
let kTHGameLoginSuccessfulNotificationKey = "\(kConstantPrefix)GameLoginSuccessfulNotification"
let kTHGameLogoutNotificationKey = "\(kConstantPrefix)GameLogoutNotification"


// MARK:- view identifiers
let kTHFriendsChallengeCellTableViewCellIdentifier = "\(kConstantPrefix)FriendsChallengeCellTableViewCellIdentifier"
let kTHHomeTurnChallengesTableViewCellIdentifier = "\(kConstantPrefix)HomeTurnChallengesTableViewCellIdentifier"

// MARK:- cache keys
let kTHUserFriendsCacheStoreKey = "\(kConstantPrefix)UserFriendsCacheStore"
let kTHUserCacheStoreKeyPrefix = "\(kConstantPrefix)UserCacheStoreID"