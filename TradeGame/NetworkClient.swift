//
//  NetworkClient.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Models

typealias loginSuccessClosure = (user: THUser?) -> ()

class NetworkClient {

    class var sharedClient: NetworkClient {
    struct Singleton {
        static let instance = NetworkClient()
        }
        
        return Singleton.instance
    }
    
    var authenticatedUser: THUser!
    
    func loginUserWithBasicAuth(username: String, password:String, loginSuccessHandler:loginSuccessClosure) -> Bool {
        let param: [String: AnyObject] = ["clientType": 1, "clientVersion" : "2.3.0"]
        
        var headers = AF.Manager.sharedInstance.defaultHeaders
        headers["TH-Client-Version"] = "2.3.0.4245"
        headers["TH-Client-Type"] = "1"
        headers["Authorization"] = "Basic " + "\(username):\(password)".encodeToBase64Encoding()
        headers["TH-Language-Code"] = "en-GB"
        AF.Manager.sharedInstance.defaultHeaders = headers
        
        AF.request(.POST,
            THAPIBaseURL + "/login",
            parameters: param,
            encoding: .JSON(options: NSJSONWritingOptions.PrettyPrinted))
            .responseJSON({(_, response, content, error) in
            if let responseError = error {
                println(responseError)
                return
            }
                
            if response?.statusCode == 200 {
                self.saveCredentials(username, password:password)
                
                let responseJSON = content as [String: AnyObject]
                let profileDTOPart: AnyObject? = responseJSON["profileDTO"]
                
                if let profileDTODict = profileDTOPart as? [String: AnyObject] {
                                    println(profileDTODict)
                    var loginUser = THUser(profileDTO: profileDTODict)
                    if let userGamePortfolio = self.fetchGamePortfolioForUser(loginUser.userId) {
                        loginUser.gamePortfolio = userGamePortfolio
                    }
                    self.authenticatedUser = loginUser
                    loginSuccessHandler(user: loginUser)
                }
            }
        })
        
        return false
    }
    
    func fetchGamePortfolioForUser(userID: Int) -> GamePortfolio? {
        
        return GamePortfolio(gamePfID: 1000, rank: "Novice")
    }
    
    func saveCredentials(username: String, password:String){
        SSKeychain.setPassword("\(username):\(password)", forService: kTHGameKeychainIdentifierKey, account: kTHGameKeychainBasicAccKey)
    }
    
    func removeCredentials() {
        for userData in SSKeychain.accountsForService(kTHGameKeychainIdentifierKey) {
            if let data = userData as? [String: String] {
                SSKeychain.deletePasswordForService(kTHGameKeychainIdentifierKey, account: data["acct"])
            }
            
        }
    }
    
    class func fetchImageFromURLString(urlString: String, progressHandler: ((Int, Int) -> Void)?, completionHandler:(UIImage!, NSError!) -> Void) {
        var fetchedImage: UIImage!
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: urlString), options: SDWebImageOptions.CacheMemoryOnly, progress: progressHandler) {  (image: UIImage!, error: NSError!, _, finished:Bool, _) -> Void in
            if completionHandler != nil {
                completionHandler(image, error)
            }
            
        }
    }
}
