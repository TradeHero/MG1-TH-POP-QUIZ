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
    
    /// Credential dictionary (FB Token)
    private var credentials: String!
    
    /// default JSON encoding
    private let JSONPrettyPrinted = Alamofire.ParameterEncoding.JSON(options: NSJSONWritingOptions.PrettyPrinted)
    
    
    // MARK:- Methods
    
    /**
    Perform login with Facebook access token and completes operation by acquiring authenticated user session.
    
    :param: accessToken Facebook access token from active facebook session
    :param: loginSuccessHandler Takes a THUser and perform operation
    */
    func loginUserWithFacebookAuth(accessToken:String, errorHandler:NSError -> (), loginSuccessHandler:THUser! -> ()) {
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
                    errorHandler(responseError)
                    return
                }
                
                if response?.statusCode == 200 {
                    let responseJSON = content as [String: AnyObject]
                    let profileDTOPart: AnyObject? = responseJSON["profileDTO"]
                    
                    if let profileDTODict = profileDTOPart as? [String: AnyObject] {
                        var loginUser = THUser(profileDTO: profileDTODict)
                        self.authenticatedUser = loginUser
                        loginSuccessHandler(loginUser)
                    }
                }
            })
    }

    
    
    /**
        Create challenge by specifying number of question, opponent ID, and handles completion with a game object.
    */
    func createChallenge(numberOfQuestions:Int, opponentId:Int!, completionHandler: (Game! -> ())?) {
        var params = ["numberOfQuestions": numberOfQuestions]
        if opponentId != nil {
            params["opponentId"] = opponentId
        }
        params["opponentId"] = 471931
        configureCompulsoryHeaders()

        AF.request(.POST, "\(THGameAPIBaseURL)/create", parameters: params, encoding: JSONPrettyPrinted).responseJSON({
            _, response, content, error in
            
            if let responseError = error {
                println(responseError)
                return
            }

            if response?.statusCode == 200 {
                let responseJSON = content as [String: AnyObject]
                println(responseJSON)
                let game = Game(gameDTO: responseJSON)
                
                var initiatorID: Int!
                if let i: AnyObject = responseJSON["createdByUserId"]{
                    initiatorID = i as Int
                }
                
                var opponentID: Int!
                if let i: AnyObject = responseJSON["opponentUserId"]{
                    opponentID = i as Int
                }
                
                self.fetchUser(opponentID) {
                    user in
                    if let u = user {
                        game.opponentPlayer = u
                    }
                    
                    self.fetchUser(initiatorID) {
                        user in
                        if let u = user {
                            game.initiatingPlayer = u
                        }
                        
                        if let handler = completionHandler {
                            handler(game)
                        }
                    }
                }
                
                
            }
        })
    }
    
    /**
        GET api/Users/{userId}/GetFriends
    */
    func fetchFriendListForUser(userId:Int, errorHandler:(NSError -> ())!, completionHandler: ([THUserFriend] ->())!){
        configureCompulsoryHeaders()
        
        AF.request(.GET, "\(THServerAPIBaseURL)/Users/\(userId)/GetFriends", parameters: nil, encoding: JSONPrettyPrinted).responseJSON({
            _, response, content, error in
            if let responseError = error {
                println(responseError)
                return
            }
            var friends: [THUserFriend] = []
            if let dict = content as? [String: AnyObject] {
                let d: AnyObject? = dict["data"]
                if let friendsArray = d as? [AnyObject] {
                    for friendObj in friendsArray {
                        let friendDictionary = friendObj as [String: AnyObject]
                        friends.append(THUserFriend(friendDTO: friendDictionary))
                    }
                }
            }

            completionHandler(friends)
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
    
    
    // MARK:- Class functions
   
    ///
    /// Fetch an image from a fully qualified URL String.
    /// 
    /// :param: urlString Fully qualified URL String of the image to be fetched
    /// :param: progressHandler Refer to SDWebImageDownloaderProgressBlock
    /// :param: completionHandler process image if successfully downloaded.
    ///
    class func fetchImageFromURLString(urlString: String!, progressHandler: ((Int, Int) -> Void)?, completionHandler:(UIImage!, NSError!) -> Void) {
        
        if urlString == nil {
            return
        }
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
        return self.credentials
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
    private func saveCredentials(credentialString:String){

        SSKeychain.setPassword("\(credentialString)", forService: kTHGameKeychainIdentifierKey, account: kTHGameKeychainFacebookAccKey)
        self.credentials = credentialString
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
                let secret = SSKeychain.passwordForService(kTHGameKeychainIdentifierKey, account: kTHGameKeychainFacebookAccKey)
                self.credentials = secret ?? "none"
            }
        }
    }

    // MARK: Simple functions
    
    /**
        Fetch user with given user ID, handles with completion handler while fetches completely.
    
        :param: userId User ID to fetch
        :param: completionHandler Handles fetched user if succeed
    */
    func fetchUser(userId: Int, completionHandler: THUser! -> ()) {
        configureCompulsoryHeaders()
        
        AF.request(.GET, "\(THServerAPIBaseURL)/Users/\(userId)", parameters: nil, encoding: JSONPrettyPrinted).responseJSON({
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
