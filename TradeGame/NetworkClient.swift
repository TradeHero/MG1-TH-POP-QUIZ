//
//  NetworkClient.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Models

class NetworkClient {
    
    /// MARK:- Variables
    
    /// Singleton network client
    class var sharedClient: NetworkClient {
    struct Singleton {
        static let instance = NetworkClient()
        }
        
        return Singleton.instance
    }
    
    /// Authenticated user
    var authenticatedUser: THUser!
    
    /// MARK:- Methods
    
    
    /// 
    /// Perform login with credentials and completes operation by acquiring authenticated user session.
    ///
    /// :param: credentials Dictionary of 2 items, login ID and password
    /// :param: loginSuccessHandler Takes a THUser and perform operation
    ///
    func loginUserWithBasicAuth(credentials:[String : String], loginSuccessHandler:(user: THUser?) -> ()) -> Bool {
        let param: [String: AnyObject] = ["clientType": 1, "clientVersion" : "2.3.0"]
        
        var headers = AF.Manager.sharedInstance.defaultHeaders
        headers["TH-Client-Version"] = "2.3.0.4245"
        headers["TH-Client-Type"] = "1"
        headers["Authorization"] = generateBasicAuthHTTPHeader(credentials[kTHGameLoginIDKey]!, password: credentials[kTHGameLoginPasswordKey]!)
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
                self.saveCredentials(credentials[kTHGameLoginIDKey]!, password:credentials[kTHGameLoginPasswordKey]!)
                
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
    
    
    ///
    ///
    ///
    ///
    
    func createQuickGame() -> Game {
        return createDummyGame()
    }
    
    
    ///
    ///
    ///
    ///
    func logout() {
        self.authenticatedUser = nil
        self.removeCredentials()
    }
    
    
    
    ///
    /// Fetches game portfolio by using userID of user.
    ///
    /// :param: userID ID of user for the portfolio to be fetched.
    /// 
    /// :returns: Game portfolio of user, would not be nil normally.
    ///
    func fetchGamePortfolioForUser(userID: Int) -> GamePortfolio? {
        
        return createDummyGamePortfolio()
    }
    
    /// MARK:- Class functions
   
    ///
    /// Fetch an image from a fully qualified URL String.
    /// 
    /// :param: urlString Fully qualified URL String of the image to be fetched
    /// :param: progressHandler Refer to SDWebImageDownloaderProgressBlock
    /// :param: completionHandler process image if successfully downloaded.
    ///
    class func fetchImageFromURLString(urlString: String, progressHandler: ((Int, Int) -> Void)?, completionHandler:(UIImage!, NSError!) -> Void) {
        
        var fetchedImage: UIImage!
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: urlString), options: SDWebImageOptions.CacheMemoryOnly, progress: progressHandler) {  (image: UIImage!, error: NSError!, _, finished:Bool, _) -> Void in
            if completionHandler != nil {
                completionHandler(image, error)
            }
            
        }
    }
    
    /// MARK:- private functions
    
    ///
    /// Generate BASIC Authentication header from username and password encoded in base64.
    ///
    /// :param: username Log In ID
    /// :param: password Log In password
    ///
    private func generateBasicAuthHTTPHeader(username: String, password:String) -> String {
        return "Basic " + "\(username):\(password)".encodeToBase64Encoding()
    }
    
    ///
    /// Save credentials to system keychain for auto-login access.
    ///
    /// :param: username Log In ID
    /// :param: password Log In password
    ///
    private func saveCredentials(username: String, password:String){
        SSKeychain.setPassword("\(username):\(password)", forService: kTHGameKeychainIdentifierKey, account: kTHGameKeychainBasicAccKey)
    }
    
    /// 
    /// Remove completely credentials from system.
    ///
    private func removeCredentials() {
        for userData in SSKeychain.accountsForService(kTHGameKeychainIdentifierKey) {
            if let data = userData as? [String: String] {
                SSKeychain.deletePasswordForService(kTHGameKeychainIdentifierKey, account: data["acct"])
            }
            
        }
    }

    ///MARK:- Dummy functions 
    
    private func createDummyGame() -> Game{
        return Game(id: 1, initiator: self.authenticatedUser.gamePortfolio, opponent: GamePortfolio(gamePfID: 2000, rank: "Novice"))
    }
    
    private func createDummyGamePortfolio() -> GamePortfolio {
        return GamePortfolio(gamePfID: 1000, rank: "Novice")
    }
}
