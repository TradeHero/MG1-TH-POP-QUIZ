//
//  THCache.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 10/1/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import EGOCache
import Runes
import Argo

struct THCache {
    static let kFBFriendsDictionaryKey = "FBFriendsDictionaryKey"
    static let kTHFriendsDictionaryKey = "THFriendsDictionaryKey"

    static func objectExistForCacheKey(key: String) -> Bool {
        return EGOCache.globalCache().objectForKey(key) != nil
    }

    static func cacheUser(user: User) {
        let userCacheKey = "\(kTHUserCacheStoreKeyPrefix)\(user.userId)"
        EGOCache.globalCache().setObject(user.dictionaryRepresentation, forKey: userCacheKey)
    }
    
    static func getCachedUser(userId:Int) -> User?{
        let userCacheKey = "\(kTHUserCacheStoreKeyPrefix)\(userId)"
        let object = EGOCache.globalCache().objectForKey(userCacheKey)
        if let uJSON = object as? [String:AnyObject] {
            return User.decode(JSONValue.parse(uJSON))
        }
        return nil
    }

    //Friends List
    static func saveFriendsListToCache(facebookFriends: [THUserFriend], tradeheroFriends: [THUserFriend]) {
        let dict = [kFBFriendsDictionaryKey: facebookFriends,
                    kTHFriendsDictionaryKey: tradeheroFriends]
        EGOCache.globalCache().setObject(dict, forKey: kTHUserFriendsCacheStoreKey)
        debugPrintln("\(facebookFriends.count + tradeheroFriends.count) friends cached.")
    }

    typealias CacheFriendsTuple = (facebookFriends:[THUserFriend], tradeheroFriends:[THUserFriend])

    static func getFriendsListFromCache() -> CacheFriendsTuple {
        let object = EGOCache.globalCache().objectForKey(kTHUserFriendsCacheStoreKey)

        if let dict = object as? [String:[THUserFriend]] {
            var facebookFriends = [THUserFriend]()
            var tradeheroFriends = [THUserFriend]()

            if let fbF = dict[kFBFriendsDictionaryKey] {
                facebookFriends = fbF
                debugPrintln("Retrieved \(fbF.count) Facebook friend(s) from cache.")
            }

            if let thF = dict[kTHFriendsDictionaryKey] {
                tradeheroFriends = thF
                debugPrintln("Retrieved \(thF.count) TradeHero friend(s) from cache.")
            }

            return (facebookFriends: facebookFriends, tradeheroFriends: tradeheroFriends)

        }
        return (facebookFriends: [], tradeheroFriends: [])
    }

    static func saveRandomFBFriends(users: [THUserFriend]) {
        EGOCache.globalCache().setObject(users, forKey: kTHRandomFBFriendsCacheStoreKey)
        debugPrintln("\(users.count) random friends users cached.")
    }


    static func getRandomFBFriendsFromCache() -> [THUserFriend] {
        let object = EGOCache.globalCache().objectForKey(kTHRandomFBFriendsCacheStoreKey)

        if let arr = object as? [THUserFriend] {
            debugPrintln("Retrieved \(arr.count) random friends from cache.")
            return arr
        }
        return []
    }

    static func saveStaffListToCache(staffList: [StaffUser]) {
        var staffDicts = [[String:AnyObject]]()
        for staff in staffList {
            staffDicts.append(staff.dictionaryRepresentation)
        }
        
        EGOCache.globalCache().setObject(staffDicts, forKey: kTHStaffUserCacheStoreKey)
        debugPrintln("\(staffList.count) staff cached.")
    }

    static func getStaffListFromCache() -> [StaffUser] {
        let object = EGOCache.globalCache().objectForKey(kTHStaffUserCacheStoreKey)

        var staffUsers = [StaffUser]()
        
        if let arr = object as? [[String:AnyObject]] {
            for staffDict in arr {
                if let u = User.decode(JSONValue.parse(staffDict)){
                    let staffU = StaffUser(user: u, funnyName: (staffDict["funnyName"] as? String) ?? "")
                    staffUsers.append(staffU)

                }
            }
        }
        debugPrintln("Retrieved \(staffUsers.count) staff from cache.")
        return staffUsers
    }


    //Game
    static func saveGameToCache(game: Game, gameId: Int) {
        let gameCacheKey = "\(kTHUserCacheStoreKeyPrefix)\(gameId)"
//        EGOCache.globalCache().setObject(game, forKey: gameCacheKey)

    }

    static func getGameFromCache(gameId: Int) -> Game? {
        return nil
    }

}
