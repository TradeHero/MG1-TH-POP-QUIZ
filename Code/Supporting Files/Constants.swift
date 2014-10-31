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

var kFaceBookShare = true

let kTHFacebookAppID = "431745923529834"



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

let kTHGameKeychainFacebookAccountKey = "\(kConstantPrefix)GameKeychainFacebookAccount"

let kTHGameKeychainDeviceTokenKey = "\(kConstantPrefix)GameKeychainDeviceToken"


//MARK:- global settings key
let kTHPushNotificationOnKey = "\(kConstantPrefix)PushNotificationOn"

let kTHBackgroundMusicValueKey = "\(kConstantPrefix)BackgroundMusicValue"

let kTHSoundEffectValueKey = "\(kConstantPrefix)SoundEffectValue"

let kTHVibrationEffectOnKey = "\(kConstantPrefix)VibrationEffectOn"

let kTHNotificationHeadOnKey = "\(kConstantPrefix)NotificationHeadOn"


//MARK:- notification keys
let kTHGameLoginSuccessfulNotificationKey = "\(kConstantPrefix)GameLoginSuccessfulNotification"

let kTHGameLogoutNotificationKey = "\(kConstantPrefix)GameLogoutNotification"

let kTHGameNotificationHeadNotificationToggleKey = "\(kConstantPrefix)GameNotificationHeadNotificationToggle"

// MARK:- view identifiers
let kTHFriendsChallengeCellTableViewCellIdentifier = "\(kConstantPrefix)FriendsChallengeCellTableViewCellIdentifier"

let kTHStaffChallengeCellTableViewCellIdentifier = "\(kConstantPrefix)StaffChallengeCellTableViewCellIdentifier"

let kTHHomeTurnChallengesTableViewCellIdentifier = "\(kConstantPrefix)HomeTurnChallengesTableViewCellIdentifier"

let kTHQuickChallengeTableViewCellIdentifier = "\(kConstantPrefix)QuickChallengeTableViewCellIdentifier"

let kTHQuestionResultTableViewCellIdentifier = "\(kConstantPrefix)QuestionResultTableViewCellIdentifier"

let kTHGameResultDetailTableViewCellIdentifier = "\(kConstantPrefix)GameResultDetailTableViewCellIdentifier"

let kTHChallengesTimelineTableViewCellIdentifier = "\(kConstantPrefix)ChallengesTimelineTableViewCellIdentifier"

let kTHSettingsControlTableViewCellIdentifier = "\(kConstantPrefix)SettingsControlTableViewCellIdentifier"

let kTHSettingsSliderTableViewCellIdentifier = "\(kConstantPrefix)SettingsSliderTableViewCellIdentifier"

let kTHNotificationTableViewCellIdentifier = "\(kConstantPrefix)NotificationTableViewCellIdentifier"

// MARK:- cache keys
let kTHUserFriendsCacheStoreKey = "\(kConstantPrefix)UserFriendsCacheStore"

let kTHStaffUserCacheStoreKey = "\(kConstantPrefix)StaffUserCacheStore"

let kTHUserCacheStoreKeyPrefix = "\(kConstantPrefix)UserCacheStoreID"

let kGameCacheStoreIDPrefix = "\(kConstantPrefix)GameCacheStoreID"

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
        musicPlayer.volume = newValue
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
        let on = newValue ? "on": "off"
        debugPrintln("Vibration effect set to \(on)")
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: newValue), forKey: kTHVibrationEffectOnKey)
    }

    get {
        if let obj = NSUserDefaults.standardUserDefaults().objectForKey(kTHVibrationEffectOnKey) as? NSNumber {
            return obj.boolValue
        }
        return false
    }
}

var kTHNotificationHeadOn:Bool {
   set {
      let show = newValue ? "show": "hidden"
      debugPrintln("Notification head set to \(show)")
      NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: newValue), forKey: kTHNotificationHeadOnKey)
      NSNotificationCenter.defaultCenter().postNotificationName(kTHGameNotificationHeadNotificationToggleKey, object: nil)
   }

   get {
      if let obj = NSUserDefaults.standardUserDefaults().objectForKey(kTHNotificationHeadOnKey) as? NSNumber {
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

typealias StaffInfo = (name:String, id:Int, funnyName:String)

var staffs_g: [StaffInfo] = {
    var staffInfo = [StaffInfo]()
    
    staffInfo.append((name:"Dinesh", id: 1156, funnyName:"High Frequency TradeHero"))
    staffInfo.append((name:"Dominic", id: 1180, funnyName:"GW2310FB-1"))
    staffInfo.append((name:"Seb", id: 527887, funnyName:"Toast Provisioner"))
    staffInfo.append((name:"Stella", id: 653913, funnyName:"The Whip"))
    staffInfo.append((name:"Ryne", id: 2415, funnyName:"Mind muncher"))
    staffInfo.append((name:"Albert", id: 593250, funnyName:"Protector of Pixels"))
    staffInfo.append((name:"Jinesh", id: 589267, funnyName:"Third Eye"))
    staffInfo.append((name:"Xavier", id: 313346, funnyName:"Code Landscapist"))
    staffInfo.append((name:"Cheryl", id: 429690, funnyName:"The Sleuth"))
    staffInfo.append((name:"Sai Heng", id: 320258, funnyName:"Postman"))
    staffInfo.append((name:"Tho", id: 251480, funnyName:"(╯°□°）╯︵ ┻━┻"))
    staffInfo.append((name:"Maddy", id: 326664, funnyName:"The One"))
    staffInfo.append((name:"Arup", id: 475785, funnyName:"The Magnet"))
    staffInfo.append((name:"Eva", id: 298275, funnyName:"Ads Addict"))
    staffInfo.append((name:"Vivian", id: 527491, funnyName:""))
    staffInfo.append((name:"James", id: 6627, funnyName:"Ni Hao"))
//    staffInfo.append((name:"Yurike Chandra", id: 0, funnyName:"Designer"))
    staffInfo.append((name:"Malvin", id: 542968, funnyName:""))
//    staffInfo.append((name:"Vincent Tee", id: 0, funnyName:"BigFoot"))
//    staffInfo.append((name:"Akash Kedia", id: 0, funnyName:"The Godfather"))
    staffInfo.append((name:"Sathya", id: 511858, funnyName:"The Imp"))
    staffInfo.append((name:"Daniel", id: 531201, funnyName:""))
    
    staffInfo.append((name:"Constant", id: 3488, funnyName:"C3PO"))
//    staffInfo.append((name:"David", id: 0, funnyName:"Hardcore Player"))
//    staffInfo.append((name:"Jeff", id: 0, funnyName:"Captain China"))
    staffInfo.append((name:"Alex", id: 426236, funnyName:"Bricklayer"))
    staffInfo.append((name:"Jack", id: 552948, funnyName:"Arrow in the knee"))
//    staffInfo.append((name:"Jason Zhao", id: 0, funnyName:"Fireman"))
    staffInfo.append((name:"Arno", id: 438063, funnyName:"Rain Maker"))
    staffInfo.append((name:"Erin", id: 536172, funnyName:""))
    staffInfo.append((name:"William", id: 518543, funnyName:""))
//    staffInfo.append((name:"Takun Chen", id: 0, funnyName:""))
    staffInfo.append((name:"Alvin", id: 250163, funnyName:""))
    return staffInfo
}()

