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

    static func getCachedUser(userId: Int) -> User? {
        let userCacheKey = "\(kTHUserCacheStoreKeyPrefix)\(userId)"
        let object = EGOCache.globalCache().objectForKey(userCacheKey)
        if let uJSON = object as? [String:AnyObject] {
            return User.decode(JSONValue.parse(uJSON))
        }
        return nil
    }

    //Friends List
    static func saveFriendsListToCache(facebookFriends: [UserFriend], tradeheroFriends: [UserFriend]) {
        let fbFriendDicts = facebookFriends.map { $0.dictionaryRepresentation }
        let thFriendDicts = tradeheroFriends.map { $0.dictionaryRepresentation }
        
        let dict: [String:AnyObject] = [kFBFriendsDictionaryKey: fbFriendDicts,
                    kTHFriendsDictionaryKey: thFriendDicts]
        EGOCache.globalCache().setObject(dict, forKey: kTHUserFriendsCacheStoreKey)
        debugPrintln("\(fbFriendDicts.count + thFriendDicts.count) friends cached.")
    }

    typealias CacheFriendsTuple = (facebookFriends:[UserFriend], tradeheroFriends:[UserFriend])

    static func getFriendsListFromCache() -> CacheFriendsTuple {
        let object = EGOCache.globalCache().objectForKey(kTHUserFriendsCacheStoreKey)

        if let dict = object as? [String:[[String:AnyObject]]] {
            var facebookFriends = [UserFriend]()
            var tradeheroFriends = [UserFriend]()

            if let fbF = dict[kFBFriendsDictionaryKey] {
                for fbFDict in fbF {
                    if let uf = UserFriend.decode(JSONValue.parse(fbFDict)) {
                        facebookFriends.append(uf)
                    }
                }
                debugPrintln("Retrieved \(facebookFriends.count) Facebook friend(s) from cache.")
            }

            if let thF = dict[kTHFriendsDictionaryKey] {
                for thFDict in thF {
                    if let uf = UserFriend.decode(JSONValue.parse(thFDict)) {
                        tradeheroFriends.append(uf)
                    }
                }
                debugPrintln("Retrieved \(tradeheroFriends.count) TradeHero friend(s) from cache.")
            }

            return (facebookFriends: facebookFriends, tradeheroFriends: tradeheroFriends)

        }
        return (facebookFriends: [], tradeheroFriends: [])
    }

    static func saveRandomFBFriends(users: [UserFriend]) {
        EGOCache.globalCache().setObject(users.map {
            $0.dictionaryRepresentation
            }, forKey: kTHRandomFBFriendsCacheStoreKey)
        debugPrintln("\(users.count) random friends users cached.")
    }


    static func getRandomFBFriendsFromCache() -> [UserFriend] {
        let object = EGOCache.globalCache().objectForKey(kTHRandomFBFriendsCacheStoreKey)
        var friends = [UserFriend]()
        if let arr = object as? [[String:AnyObject]] {
            for FDict in arr {
                if let uf = UserFriend.decode(JSONValue.parse(FDict)) {
                    friends.append(uf)
                }
            }
            return friends
        }
        return []
    }

    static func saveStaffListToCache(staffList: [StaffUser]) {
        var staffDicts = [[String: AnyObject]]()
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
                if let u = User.decode(JSONValue.parse(staffDict)) {
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
        EGOCache.globalCache().setObject(game.dictionaryRepresentation, forKey: gameCacheKey)

    }

    static func getGameFromCache(gameId: Int) -> Game? {
        let gameCacheKey = "\(kTHUserCacheStoreKeyPrefix)\(gameId)"
        let object = EGOCache.globalCache().objectForKey(gameCacheKey)
        if let gJSON = object as? [String:AnyObject] {
            return Game.decode(JSONValue.parse(gJSON))
        }
        return nil
    }

}
