//
//  THCache.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 10/1/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

struct THCache {
    static let kFBFriendsDictionaryKey = "FBFriendsDictionaryKey"
    static let kTHFriendsDictionaryKey = "THFriendsDictionaryKey"
    
    //User
    static func saveUserToCache(user:THUser, userId:Int){
        let userCacheKey = "\(kTHUserCacheStoreKeyPrefix)\(userId)"
        EGOCache.globalCache().setObject(user, forKey: userCacheKey)
    }
    
    static func getUserFromCache(userId:Int) -> THUser? {
        let userCacheKey = "\(kTHUserCacheStoreKeyPrefix)\(userId)"
        let object = EGOCache.globalCache().objectForKey(userCacheKey)
        if let user = object as? THUser {
            return user
        }
        return nil
    }
    
    
    //Friends List
    static func saveFriendsListToCache(facebookFriends:[THUserFriend], tradeheroFriends:[THUserFriend]) {
        let dict = [kFBFriendsDictionaryKey: facebookFriends,
                    kTHFriendsDictionaryKey: tradeheroFriends]
        EGOCache.globalCache().setObject(dict, forKey: kTHUserFriendsCacheStoreKey)
        debugPrintln("\(facebookFriends.count + tradeheroFriends.count) friends cached.")
    }
    
    typealias CacheFriendsTuple = (facebookFriends:[THUserFriend], tradeheroFriends:[THUserFriend])
    static func getFriendsListFromCache() -> CacheFriendsTuple{
        let object = EGOCache.globalCache().objectForKey(kTHUserFriendsCacheStoreKey)
        
        if let dict = object as? [String: [THUserFriend]] {
            var facebookFriends = [THUserFriend]()
            var tradeheroFriends = [THUserFriend]()
            
            if let fbF = dict[kFBFriendsDictionaryKey] {
                facebookFriends = fbF
                debugPrintln("Retrieved \(fbF.count) Facebook friend(s) from cache.")
            }
            
            if let thF = dict[kTHFriendsDictionaryKey]{
                tradeheroFriends = thF
                debugPrintln("Retrieved \(thF.count) TradeHero friend(s) from cache.")
            }
            
            return (facebookFriends: facebookFriends, tradeheroFriends:tradeheroFriends)
            
        }
        return (facebookFriends:[], tradeheroFriends:[])
    }
    
    //Game
    static func saveGameToCache(game:Game, gameId:Int){
        let gameCacheKey = "\(kTHUserCacheStoreKeyPrefix)\(gameId)"
//        EGOCache.globalCache().setObject(game, forKey: gameCacheKey)

    }
    
    static func getGameFromCache(gameId:Int) -> Game? {
        return nil
    }
    
}
