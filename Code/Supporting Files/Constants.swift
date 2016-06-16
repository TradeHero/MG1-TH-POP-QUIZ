//
//  Constants.swift
//  TH-PopQuiz
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

let kTHFacebookURLScheme = "fb\(kTHFacebookAppID)thpopquiz"

let kTHFacebookPermissionOption = ["public_profile", "email", "user_friends"]

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

let kTHDefaultSongKey = "\(kConstantPrefix)DefaultSong"

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

let kTHSettingsCommonTableViewCellIdentifier = "\(kConstantPrefix)SettingsCommonTableViewCellIdentifier"

let kTHNotificationTableViewCellIdentifier = "\(kConstantPrefix)NotificationTableViewCellIdentifier"

let kTHMusicChooserTableViewCellIdentifier = "\(kConstantPrefix)MusicChooserTableViewCellIdentifier"
// MARK:- cache keys
let kTHUserFriendsCacheStoreKey = "\(kConstantPrefix)UserFriendsCacheStore"

let kTHStaffUserCacheStoreKey = "\(kConstantPrefix)StaffUserCacheStoreKey"

let kTHUserCacheStoreKeyPrefix = "\(kConstantPrefix)UserCacheStoreID"

let kGameCacheStoreIDPrefix = "\(kConstantPrefix)GameCacheStoreID"

let kTHRandomFBFriendsCacheStoreKey = "\(kConstantPrefix)RandomFBFriendsCacheStore"

//MARK:- Settings
var kTHPushNotificationOn: Bool {
    set {
        debugPrint("Push notifications set to \(newValue)")
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

var kTHBackgroundMusicValue: Float {
    set {
        debugPrint("Background music volume set to \(newValue)")
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(float: newValue), forKey: kTHBackgroundMusicValueKey)
//        musicPlayer.volume = newValue
    }

    get {
        if let obj = NSUserDefaults.standardUserDefaults().objectForKey(kTHBackgroundMusicValueKey) as? NSNumber {
            return obj.floatValue
        }
        return 0.5
    }
}

var kTHSoundEffectValue: Float {
    set {
        debugPrint("Sound effect volume set to \(newValue)")
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(float: newValue), forKey: kTHSoundEffectValueKey)
    }

    get {
        if let obj = NSUserDefaults.standardUserDefaults().objectForKey(kTHSoundEffectValueKey) as? NSNumber {
            return obj.floatValue
        }
        return 0.25
    }
}

var kTHVibrationEffectOn: Bool {
    set {
        let on = newValue ? "on" : "off"
        debugPrint("Vibration effect set to \(on)")
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: newValue), forKey: kTHVibrationEffectOnKey)
    }

    get {
        if let obj = NSUserDefaults.standardUserDefaults().objectForKey(kTHVibrationEffectOnKey) as? NSNumber {
            return obj.boolValue
        }
        return false
    }
}

var kTHNotificationHeadOn: Bool {
    set {
        let show = newValue ? "show" : "hidden"
        debugPrint("Notification head set to \(show)")
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

var kTHDefaultSong = ""

//var kTHDefaultSong: String {
//    set {
//        debugPrint("Default background music set to \(newValue)")
//        NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: kTHDefaultSongKey)
//    }
//
//    get {
//        if let obj = NSUserDefaults.standardUserDefaults().objectForKey(kTHDefaultSongKey) as? String {
//            return obj
//        }
//
//        return getRandomMusicName()
//    }
//}

func vibrateIfAllowed() {
    if kTHVibrationEffectOn {
        AudioServicesPlayAlertSound(0x00000FFF)
    }
}

typealias StaffInfo = (name:String, id:Int, funnyName:String)

var staffs_g: [StaffInfo] = {
    var staffInfo = [StaffInfo]()

    staffInfo.append((name: "Dinesh", id: 1156, funnyName: "High Frequency TradeHero"))
    staffInfo.append((name: "Dominic", id: 1180, funnyName: "GW2310FB-1"))
    staffInfo.append((name: "Seb", id: 527887, funnyName: "Toast Provisioner"))
    staffInfo.append((name: "Stella", id: 653913, funnyName: "The Whip"))
    staffInfo.append((name: "Ryne", id: 2415, funnyName: "Mind muncher"))
    staffInfo.append((name: "Albert", id: 593250, funnyName: "Protector of Pixels"))
    staffInfo.append((name: "Jinesh", id: 589267, funnyName: "Third Eye"))
    staffInfo.append((name: "Xavier", id: 102700, funnyName: "Code Landscapist"))
    staffInfo.append((name: "Cheryl", id: 429690, funnyName: "The Sleuth"))
    staffInfo.append((name: "Sai Heng", id: 320258, funnyName: "Postman"))
    staffInfo.append((name: "Tho", id: 108805, funnyName: "(╯°□°）╯︵ ┻━┻"))
    staffInfo.append((name: "Maddy", id: 326664, funnyName: "The One"))
    staffInfo.append((name: "Arup", id: 475785, funnyName: "The Magnet"))
    staffInfo.append((name: "Eva", id: 298275, funnyName: "Ads Addict"))
    staffInfo.append((name: "Vivian", id: 527491, funnyName: ""))
    staffInfo.append((name: "James", id: 6627, funnyName: "Li Hao"))
//    staffInfo.append((name:"Yurike Chandra", id: 0, funnyName:"Designer"))
    staffInfo.append((name: "Malvin", id: 542968, funnyName: ""))
//    staffInfo.append((name:"Vincent Tee", id: 0, funnyName:"BigFoot"))
//    staffInfo.append((name:"Akash Kedia", id: 0, funnyName:"The Godfather"))
    staffInfo.append((name: "Sathya", id: 511858, funnyName: "The Imp"))
    staffInfo.append((name: "Daniel", id: 531201, funnyName: ""))

    staffInfo.append((name: "Constant", id: 3488, funnyName: "C3PO"))
//    staffInfo.append((name:"David", id: 0, funnyName:"Hardcore Player"))
//    staffInfo.append((name:"Jeff", id: 0, funnyName:"Captain China"))
    staffInfo.append((name: "Alex", id: 426236, funnyName: "Bricklayer"))
    staffInfo.append((name: "Jack", id: 552948, funnyName: "Arrow in the knee"))
//    staffInfo.append((name:"Jason Zhao", id: 0, funnyName:"Fireman"))
    staffInfo.append((name: "Arno", id: 438063, funnyName: "Rain Maker"))
    staffInfo.append((name: "Erin", id: 536172, funnyName: ""))
    staffInfo.append((name: "William", id: 518543, funnyName: ""))
//    staffInfo.append((name:"Takun Chen", id: 0, funnyName:""))
    staffInfo.append((name: "Alvin", id: 250163, funnyName: ""))
    staffInfo.append((name: "Nihal", id: 545862, funnyName: "Ni Hao"))
    return staffInfo
}()

func isInternalUser(user: User) -> Bool {
    var users = staffs_g.filter({ $0.id == user.userId })
    return users.count == 1
}

func getClassName(classType: AnyClass) -> String {

    let classString = NSStringFromClass(classType.self)
    let range = classString.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch, range: Range<String.Index>(start: classString.startIndex, end: classString.endIndex), locale: nil)
    return classString.substringFromIndex(range!.endIndex)
}
