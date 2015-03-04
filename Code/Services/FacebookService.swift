//
//  FacebookService.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 12/2/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import FacebookSDK
import Social
import Accounts
import Argo

enum FacebookConnectOption {
    case NativeFallBack
    case SDKOnly
}

class FacebookService {
    private var accountStore = ACAccountStore()
    
    private var facebookAccount: ACAccount!
    
    class var sharedService: FacebookService {
        
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var instance: FacebookService!
        }
        
        dispatch_once(&Singleton.onceToken) {
            Singleton.instance = FacebookService()
        }
        
        return Singleton.instance
    }
    
    func connect(completionHandler: (String!, NSError!) -> (), connectOption: FacebookConnectOption = .NativeFallBack) {
        switch connectOption {
        case .NativeFallBack:
            nativeFallbackWithSDKConnect(completionHandler)
        case .SDKOnly:
            FBSession.activeSession().closeAndClearTokenInformation()
            FacebookConnectWithSDK {
                [unowned self] session, error in
                if let e = error {
                    completionHandler(nil, error)
                }
                let accessToken = session.accessTokenData.accessToken
                completionHandler(accessToken, nil)
            }
        }
    }
    
    func FacebookConnectWithSDK(completionHandler: (FBSession!, NSError!) -> ()) {
        dispatch_async(dispatch_get_main_queue(), {
            FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_birthday", "user_likes"], allowLoginUI: true, completionHandler: {
                (session, state, error) -> Void in
                    completionHandler(session, error)
                }
            )
            return
        })
        
    }
    
    func renewFacebookToken(completionHandler: (FBSession!, NSError!) -> ()) {
        dispatch_async(dispatch_get_main_queue(), {
            FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_birthday", "user_likes"], allowLoginUI: true, completionHandler: {
                (session, state, error) -> Void in
                completionHandler(session, error)
                }
            )
            return
        })
        
    }
    
    private func nativeFallbackWithSDKConnect(completionHandler: (String!, NSError!) -> ()) {
        let facebookTypeAccount = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
        accountStore.requestAccessToAccountsWithType(facebookTypeAccount, options: [ACFacebookAppIdKey: kTHFacebookAppID, ACFacebookPermissionsKey: ["user_birthday, email"]]) {
            [unowned self] (granted, error) -> Void in
            if granted {
                if let accts = self.accountStore.accountsWithAccountType(facebookTypeAccount) as? [ACAccount] {
                    self.facebookAccount = accts.last
                    let accessToken = self.facebookAccount.credential.oauthToken
                    completionHandler(accessToken, nil)
                }
            } else {
                if let e = error {
                    if error.code == Int(ACErrorAccountNotFound.value) {
                        // use SDK login
                        self.FacebookConnectWithSDK {
                            session, error in
                            if let e = error {
                                completionHandler(nil, error)
                            }
                            let accessToken = session.accessTokenData.accessToken
                            completionHandler(accessToken, nil)
                        }
                    }
                }
            }
        }
    }
    
    func getInvitableFriends(completionHandler:[FacebookInvitableFriend]->()){
        FBRequestConnection.startWithGraphPath("/me/invitable_friends", parameters: nil, HTTPMethod: "GET")
            { (conn, result, error) -> Void in
                if let res = result as? [String: AnyObject]{
                    let data: AnyObject? = res["data"]
                    if let d = data as? [AnyObject]{
                        var invitableFriends = [FacebookInvitableFriend]()
                        for rawFriend in d {
                            if let friendConverted = FacebookInvitableFriend.decode(JSONValue.parse(rawFriend)){
                                invitableFriends.append(friendConverted)
                            }
                        }
                        completionHandler(invitableFriends);
                    }
                }
        }

    }
    
    func presentInviteFriendsDialog(message:String!, friendsToInvite:[FacebookInvitableFriend]){
        var inviteTokens = getCommaSeparatedTokens(friendsToInvite);
        let params = ["to": inviteTokens, "method": "apprequests"];
        FBWebDialogs.presentRequestsDialogModallyWithSession(nil, message: message, title: nil, parameters: params) { (result, url, err) -> Void in
            if let e = err {
                println(e)
            } else {
                if(result == .DialogNotCompleted){
                    println("User canceled request")
                } else {
                    //Handle the send request callback
                    
                }
            }
        }
    }
    
    func getCommaSeparatedTokens(friends:[FacebookInvitableFriend]) -> String {
        if(friends.isEmpty) {return "";}
        if(friends.count == 1) {return friends[0].inviteToken;}
        
        var csv = ""
        for friend in friends {
            csv += "\(friend.inviteToken),"
        }
        
        csv = csv.substringToIndex(csv.endIndex.predecessor())
        
        return csv;
    }
}
