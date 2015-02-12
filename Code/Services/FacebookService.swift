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
}

