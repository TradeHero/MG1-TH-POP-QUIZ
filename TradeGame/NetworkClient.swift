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
    
    
    ///
    private var credentials: [String: String]!
    
    /// default JSON encoding
    private let JSONPrettyPrinted = Alamofire.ParameterEncoding.JSON(options: NSJSONWritingOptions.PrettyPrinted)
    
    
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
        headers = configureDefaultHTTPHeaders(headers)
        headers["Authorization"] = generateBasicAuthHTTPHeader(credentials[kTHGameLoginIDKey]!, password: credentials[kTHGameLoginPasswordKey]!)
        AF.Manager.sharedInstance.defaultHeaders = headers
        
        AF.request(.POST,
            THServerAPIBaseURL + "/login",
            parameters: param,
            encoding: JSONPrettyPrinted)
            .responseJSON({
                _, response, content, error in
            if let responseError = error {
                println(responseError)
                return
            }
                
            if response?.statusCode == 200 {
                self.saveCredentials(credentials)
                
                let responseJSON = content as [String: AnyObject]
                let profileDTOPart: AnyObject? = responseJSON["profileDTO"]
                
                if let profileDTODict = profileDTOPart as? [String: AnyObject] {
//                                    println(profileDTODict)
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
    func createChallenge(numberOfQuestions:Int, user:THUser, completionHandler: (Game -> ())?) {
        let params = ["opponentId": user.userId, "numberOfQuestions": numberOfQuestions]
        
        var headers = AF.Manager.sharedInstance.defaultHeaders
        headers = configureDefaultHTTPHeaders(headers)
        headers["Authorization"] = generateAuthorisationFromKeychain()
        AF.Manager.sharedInstance.defaultHeaders = headers

        AF.request(.POST, "\(THGameAPIBaseURL)/create", parameters: params, encoding: JSONPrettyPrinted).responseJSON({
            _, response, content, error in
            if let responseError = error {
                println(responseError)
                return
            }

            if response?.statusCode == 200 {
                println(content!)
            }
        })
    }
    
    ///
    ///
    ///
    ///
    func createQuickGame() -> Game {
        var g: Game? = nil
        createChallenge(10, user: self.authenticatedUser, completionHandler: {
            game in
            g = game
        })
        
        return Game(id: 1, initiator: GamePortfolio(gamePfID: 1, rank: "n0"), opponent: GamePortfolio(gamePfID: 2, rank: "x"))
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
    
    
    
    private func configureDefaultHTTPHeaders(dict:[String : String]) -> [String : String]{
        var headers = dict
        if (headers["TH-Client-Version"] == nil) {
            headers["TH-Client-Version"] = "2.3.0.4245"
        }
        
        if (headers["TH-Client-Type"] == nil) {
            headers["TH-Client-Type"] = "1"
        }
        
        if (headers["TH-Language-Code"] == nil) {
            headers["TH-Language-Code"] = "en-GB"
        }
        return headers
    }
    
    
    private func generateAuthorisationFromKeychain() -> String? {
        self.loadCredentials()
        if let cred = self.credentials {
            return generateBasicAuthHTTPHeader(self.credentials[kTHGameLoginIDKey]!, password: self.credentials[kTHGameLoginPasswordKey]!)
        }
        return nil
    }
    
    
    
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
    private func saveCredentials(credentials:[String: String]){

        SSKeychain.setPassword("\(credentials[kTHGameLoginIDKey]!):\(credentials[kTHGameLoginPasswordKey]!)", forService: kTHGameKeychainIdentifierKey, account: kTHGameKeychainBasicAccKey)
        self.credentials = credentials
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
        self.credentials = nil
    }
    
    private func loadCredentials() {
        let keychainAcc = SSKeychain.accountsForService(kTHGameKeychainIdentifierKey)
        if keychainAcc.count == 0 {
            println("No credentials found")
        }
        
        for userData in keychainAcc {
            if let data = userData as? [String: String] {
                let secret = SSKeychain.passwordForService(kTHGameKeychainIdentifierKey, account: kTHGameKeychainBasicAccKey)
                let credArr = secret.componentsSeparatedByString(":")
                let credDict = [kTHGameLoginIDKey : credArr[0], kTHGameLoginPasswordKey : credArr[1]]
                self.credentials = credDict
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
