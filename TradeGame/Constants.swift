//
//  Constants.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/6/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import Foundation

let kConstantPrefix = "TH"


// MARK:- connections

let kConnectionHTTPS = "https://"
let THAPIHost: String = "www.tradehero.mobi"
let THAPIPath: String = "/api"
let THAPIBaseURL: String = "\(kConnectionHTTPS)\(THAPIHost)\(THAPIPath)"
let THMiniGameAPIBaseURL: String =  "\(THAPIBaseURL)/games"


// MARK:- keys

let kTHGameLoggedInKey: String = "\(kConstantPrefix)GameLoggedIn"
let kTHGameLoginIDKey: String = "\(kConstantPrefix)GameLoginID"
let kTHGameLoginPasswordKey: String = "\(kConstantPrefix)GameLoginPassword"
let kTHGameKeychainIdentifierKey: String = "\(kConstantPrefix)GameKeychainIdentifier"
let kTHGameKeychainBasicAccKey: String = "\(kConstantPrefix)GameKeychainBasicAcc"