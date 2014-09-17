//
//  Constants.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/6/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import Foundation
import AudioToolbox

enum Mode: Int {
    case Staging
    case Prod
}

let TestFlightToken = "c1a29f46-4c93-4e9a-8b89-0ec297bf1622"

let kTHGamesServerMode = Mode.Staging

let kConstantPrefix = "TH"

// MARK:- connections

let kConnectionHTTPS = "https://"
let kConnectionHTTP = "http://"
let THAPIPath = "/api"

let THProdAPIHost = "www.tradehero.mobi"
let THProdAPIBaseURL = "\(kConnectionHTTPS)\(THProdAPIHost)\(THAPIPath)"

let THDevAPIHost = "th-paas-test-dev1.cloudapp.net"
let THDevAPIBaseURL = "\(kConnectionHTTP)\(THDevAPIHost)\(THAPIPath)"

let THServerAPIBaseURL = kTHGamesServerMode == Mode.Staging ? "\(THDevAPIBaseURL)" : "\(THProdAPIBaseURL)"

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


let kTHPushNotificationOnKey = "\(kConstantPrefix)PushNotificationOn"

let kTHBackgroundMusicValueKey = "\(kConstantPrefix)BackgroundMusicValue"

let kTHSoundEffectValueKey = "\(kConstantPrefix)SoundEffectValue"

let kTHVibrationEffectOnKey = "\(kConstantPrefix)VibrationEffectOn"


//MARK:- notification keys
let kTHGameLoginSuccessfulNotificationKey = "\(kConstantPrefix)GameLoginSuccessfulNotification"

let kTHGameLogoutNotificationKey = "\(kConstantPrefix)GameLogoutNotification"



// MARK:- view identifiers
let kTHFriendsChallengeCellTableViewCellIdentifier = "\(kConstantPrefix)FriendsChallengeCellTableViewCellIdentifier"

let kTHHomeTurnChallengesTableViewCellIdentifier = "\(kConstantPrefix)HomeTurnChallengesTableViewCellIdentifier"

let kTHQuickChallengeTableViewCellIdentifier = "\(kConstantPrefix)QuickChallengeTableViewCellIdentifier"

let kTHQuestionResultTableViewCellIdentifier = "\(kConstantPrefix)QuestionResultTableViewCellIdentifier"

let kTHGameResultDetailTableViewCellIdentifier = "\(kConstantPrefix)GameResultDetailTableViewCellIdentifier"

let kTHChallengesTimelineTableViewCellIdentifier = "\(kConstantPrefix)ChallengesTimelineTableViewCellIdentifier"

let kTHSettingsControlTableViewCellIdentifier = "\(kConstantPrefix)SettingsControlTableViewCellIdentifier"

let kTHSettingsSliderTableViewCellIdentifier = "\(kConstantPrefix)SettingsSliderTableViewCellIdentifier"


// MARK:- cache keys
let kTHUserFriendsCacheStoreKey = "\(kConstantPrefix)UserFriendsCacheStore"

let kTHUserCacheStoreKeyPrefix = "\(kConstantPrefix)UserCacheStoreID"



//MARK:- Settings
var kTHPushNotificationOn:Bool {
    set {
        debugPrintln("Push notifications set to \(newValue)")
//    NetworkClient.sharedClient.updatePushNotification() 
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: newValue), forKey: kTHPushNotificationOnKey)
    }

    get {
        if let obj = NSUserDefaults.standardUserDefaults().objectForKey(kTHPushNotificationOnKey) as? NSNumber {
            return obj.boolValue
        }
        return true
    }
}

var kTHBackgroundMusicValue:Float {
    set {
        debugPrintln("Background music volume set to \(newValue)")
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(float: newValue), forKey: kTHBackgroundMusicValueKey)
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
            app.bgmPlayer.volume = newValue
        }
    }
    
    get {
        if let obj = NSUserDefaults.standardUserDefaults().objectForKey(kTHBackgroundMusicValueKey) as? NSNumber {
            return obj.floatValue
        }
        return 1
    }
}

var kTHSoundEffectValue:Float {
    set {
        debugPrintln("Sound effect volume set to \(newValue)")
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(float: newValue), forKey: kTHSoundEffectValueKey)
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
            app.soundEffectPlayer.volume = newValue
        }
    }
    
    get {
        if let obj = NSUserDefaults.standardUserDefaults().objectForKey(kTHSoundEffectValueKey) as? NSNumber {
            return obj.floatValue
        }
        return 1
    }
}
var kTHVibrationEffectOn:Bool {
    set {
        debugPrintln("Vibration effect set to \(newValue)")
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: newValue), forKey: kTHVibrationEffectOnKey)
    }

    get {
        if let obj = NSUserDefaults.standardUserDefaults().objectForKey(kTHVibrationEffectOnKey) as? NSNumber {
            return obj.boolValue
        }
        return false
    }
}

func vibrateIfAllowed(){
    if kTHVibrationEffectOn {
        AudioServicesPlayAlertSound(0x00000FFF)
    }
}