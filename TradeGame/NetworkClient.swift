//
//  NetworkClient.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class NetworkClient {
    
    // MARK:- Variables
    
    /// Singleton network client
    class var sharedClient: NetworkClient {
    struct Singleton {
        static let instance = NetworkClient()
        }
        
        return Singleton.instance
    }
    
    /// Authenticated user
    var authenticatedUser: THUser! {
        didSet{
            if self.authenticatedUser != nil {
                println("Signed in as \(self.authenticatedUser)")
            }
        }
    }
    
    
    /// Credential dictionary (BASIC Auth)
    private var credentials: [String: String]!
    
    /// default JSON encoding
    private let JSONPrettyPrinted = Alamofire.ParameterEncoding.JSON(options: NSJSONWritingOptions.PrettyPrinted)
    
    // MARK:- Methods
    
    /**
        Perform login with credentials and completes operation by acquiring authenticated user session.
    
        :param: credentials Dictionary of 2 items, login ID and password
        :param: loginSuccessHandler Takes a THUser and perform operation
    */
    func loginUserWithBasicAuth(credentials:[String : String], loginSuccessHandler:THUser? -> ()) -> Bool {
        let param: [String: AnyObject] = ["clientType": 1, "clientVersion" : "2.3.0"]
        
        
        var headers = AF.Manager.sharedInstance.defaultHeaders
        if (headers["TH-Client-Version"] == nil) {
            headers["TH-Client-Version"] = "2.3.0.4245"
        }
        
        if (headers["TH-Client-Type"] == nil) {
            headers["TH-Client-Type"] = "1"
        }
        
        if (headers["TH-Language-Code"] == nil) {
            headers["TH-Language-Code"] = "en-GB"
        }
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
//                    println(profileDTODict)
                    var loginUser = THUser(profileDTO: profileDTODict)
//                    if let userGamePortfolio = self.fetchGamePortfolioForUser(loginUser.userId) {
//                        loginUser.gamePortfolio = userGamePortfolio
//                    }
                    self.authenticatedUser = loginUser
                    loginSuccessHandler(loginUser)
                }
            }
        })
        
        return false
    }
    
    func loginUserWithFacebookAuth(accessToken:String, loginSuccessHandler:THUser? -> ()) -> Bool {
        let param: [String: AnyObject] = ["clientType": 1, "clientVersion" : "2.3.0"]
        
        
        var headers = AF.Manager.sharedInstance.defaultHeaders
        if (headers["TH-Client-Version"] == nil) {
            headers["TH-Client-Version"] = "2.3.0.4245"
        }
        
        if (headers["TH-Client-Type"] == nil) {
            headers["TH-Client-Type"] = "1"
        }
        
        if (headers["TH-Language-Code"] == nil) {
            headers["TH-Language-Code"] = "en-GB"
        }
        headers["Authorization"] = "\(THAuthFacebookPrefix) \(accessToken)"
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
                    let responseJSON = content as [String: AnyObject]
                    let profileDTOPart: AnyObject? = responseJSON["profileDTO"]
                    
                    if let profileDTODict = profileDTOPart as? [String: AnyObject] {
                        //                    println(profileDTODict)
                        var loginUser = THUser(profileDTO: profileDTODict)
                        //                    if let userGamePortfolio = self.fetchGamePortfolioForUser(loginUser.userId) {
                        //                        loginUser.gamePortfolio = userGamePortfolio
                        //                    }
                        self.authenticatedUser = loginUser
                        loginSuccessHandler(loginUser)
                    }
                }
            })
        
        return false
    }

    
    
    /**
        Create challenge by specifying number of question, opponent ID, and handles completion with a game object.
    */
    func createChallenge(numberOfQuestions:Int, opponentId:Int?, completionHandler: (Game? -> ())?) {
        var params = ["numberOfQuestions": numberOfQuestions]
        if opponentId == nil {
            params["opponentId"] = 471931
        }
        
        configureCompulsoryHeaders()

        AF.request(.POST, "\(THGameAPIBaseURL)/create", parameters: params, encoding: JSONPrettyPrinted).responseJSON({
            _, response, content, error in
            
            if let responseError = error {
                println(responseError)
                return
            }

            if response?.statusCode == 200 {
                let responseJSON = content as [String: AnyObject]
                
                let gameTuple = self.createGameObjectFromDTO(responseJSON)
                self.fetchUser(gameTuple.opponentID) {
                    user in
                    if let u = user {
                        gameTuple.game.opponentPlayer = u
                    }
                    
                    self.fetchUser(gameTuple.initiatorID) {
                        user in
                        if let u = user {
                            gameTuple.game.initiatingPlayer = u
                        }
                        
                        if let handler = completionHandler {
                            handler(gameTuple.game)
                        }
                    }
                }
                
                
            }
        })
    }
    
    ///
    ///
    ///
    ///
    func createQuickGame(completionHandler: (Game? -> ())?){
        createChallenge(10, opponentId: nil, completionHandler: {
            game in
            if let handler = completionHandler {
                handler(game)
            }
        })
    }
    
    
    ///
    /// Logs out current session, removing credentials and user details stored in keychain or in device.
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
//    func fetchGamePortfolioForUser(userID: Int) -> GamePortfolio? {
//        
//        return createDummyGamePortfolio()
//    }
    
    // MARK:- Class functions
   
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
    
    // MARK:- private functions
    
    func configureCompulsoryHeaders(){
        var headers = AF.Manager.sharedInstance.defaultHeaders
        if (headers["TH-Client-Version"] == nil) {
            headers["TH-Client-Version"] = "2.3.0.4245"
        }
        
        if (headers["TH-Client-Type"] == nil) {
            headers["TH-Client-Type"] = "1"
        }
        
        if (headers["TH-Language-Code"] == nil) {
            headers["TH-Language-Code"] = "en-GB"
        }

        if let auth = generateAuthorisationFromKeychain() {
            headers["Authorization"] = auth
        }
        AF.Manager.sharedInstance.defaultHeaders = headers
    }
    
    /// 
    /// Generates authorisation header from saved credential in device keychain.
    ///
    private func generateAuthorisationFromKeychain() -> String? {
        self.loadCredentials()
        if let cred = self.credentials {
            return generateBasicAuthHTTPHeader(cred[kTHGameLoginIDKey]!, password: cred[kTHGameLoginPasswordKey]!)
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

    
    private func createGameObjectFromDTO(dto: [String: AnyObject]) -> (game:Game, initiatorID:Int, opponentID:Int) {
        var gameID: Int!
        if let id: AnyObject = dto["id"] {
            gameID = id as Int
        }
        
        var createdAtStr: String!
        if let s: AnyObject = dto["createdAtUtc"] {
            createdAtStr = s as String
        }
        
        var initiatorID: Int!
        if let i: AnyObject = dto["createdByUserId"]{
            initiatorID = i as Int
        }
        
        var opponentID: Int!
        if let i: AnyObject = dto["opponentUserId"]{
            opponentID = i as Int
        }
        
        var questionSet: [Question] = []
        if let qs: AnyObject = dto["questionSet"] {
            let questionJSON = qs as [AnyObject]
            for q in questionJSON {
                if let questionDTO = q as? [String: AnyObject] {
                    questionSet.append(Question(questionDTO: questionDTO))
                }
            }
        }
        
        let game = Game(id: gameID, createdAtUTCStr: createdAtStr, questionSet: questionSet)
        
        return (game, initiatorID, opponentID)
    }
    // MARK: Simple functions
    func fetchUser(userId: Int, completionHandler: THUser? -> ()) {
        configureCompulsoryHeaders()
        
        AF.request(.GET, "\(THServerAPIBaseURL)/users/\(userId)", parameters: nil, encoding: JSONPrettyPrinted).responseJSON({
            _, response, content, error in
            if let responseError = error {
                println(responseError)
                return
            }            
            if let profileDTODict = content as? [String: AnyObject] {
                var user = THUser(profileDTO: profileDTODict)
                completionHandler(user)
            }
            
            
        })
        
        
    }
    
    
    
}
