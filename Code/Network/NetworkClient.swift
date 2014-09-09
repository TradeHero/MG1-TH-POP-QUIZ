//
//  NetworkClient.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Alamofire

class NetworkClient {
    
    // MARK:- Variables
    
    /// Singleton network client
    class var sharedClient: NetworkClient {
    struct Singleton {
        static var onceToken : dispatch_once_t = 0
        static var instance : NetworkClient!
        }
        dispatch_once(&Singleton.onceToken) {
            Singleton.instance = NetworkClient()
            Singleton.instance.loadCredentials()
        }
        
        return Singleton.instance
    }
    
    /// Authenticated user
    var authenticatedUser: THUser!
    
    /// Credential dictionary (FB Token)
    var credentials: String!
    
    /// default JSON encoding
    private let JSONEncoding = Alamofire.ParameterEncoding.JSON
    
    // MARK:- Methods
    
    /**
    Perform login with Facebook access token and completes operation by acquiring authenticated user session.
    
    :param: accessToken Facebook access token from active facebook session
    :param: loginSuccessHandler Takes a THUser and perform operation
    */
    func loginUserWithFacebookAuth(accessToken:String, loginSuccessHandler:(THUser -> ())!) {
        let param: [String: AnyObject] = ["clientType": 1, "clientVersion" : "2.3.0"]
        
        var headers = Alamofire.Manager.sharedInstance.defaultHeaders
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
        Alamofire.Manager.sharedInstance.defaultHeaders = headers
        weak var weakSelf = self
        let r = Alamofire.request(.POST,
            THServerAPIBaseURL + "/login",
            parameters: param,
            encoding: JSONEncoding)
            .responseJSON() {
                _, response, content, error in
                var strongSelf = weakSelf!
                if let responseError = error {
                    println(responseError)
                    return
                }
                
                if response?.statusCode == 200 {
                    let responseJSON = content as [String: AnyObject]
                    let profileDTOPart: AnyObject? = responseJSON["profileDTO"]
                    
                    if let profileDTODict = profileDTOPart as? [String: AnyObject] {
                        var loginUser = THUser(profileDTO: profileDTODict)
                        println("Signed in as \(loginUser)")
                        strongSelf.authenticatedUser = loginUser
                        let userInfo = ["user": loginUser]
                        NSNotificationCenter.defaultCenter().postNotificationName(kTHGameLoginSuccessfulNotificationKey, object: self, userInfo:userInfo)
                        loginSuccessHandler(loginUser)
                    }
                }
        }
        
        //        debugPrintln(r)
    }
    
    /**
    Create challenge by specifying number of question, opponent ID, and handles completion with a game object.
    */
    func createChallenge(numberOfQuestions:Int = 7, opponentId:Int, completionHandler: (Game! -> ())!) {
        configureCompulsoryHeaders()
        debugPrintln("Creating challenge with user \(opponentId) with \(numberOfQuestions) questions(s)")
        
        weak var wself = self
        Alamofire.request(.POST, "\(THGameAPIBaseURL)/create", parameters: ["numberOfQuestions": numberOfQuestions, "opponentId" : opponentId
            ], encoding: JSONEncoding).responseJSON() {
                _, response, content, error in
                var sself = wself!
                if let responseError = error {
                    println(responseError)
                    return
                }
                
                if response?.statusCode == 200 {
                    let responseJSON = content as [String: AnyObject]
                    //                println(responseJSON)
                    var game = Game(gameDTO: responseJSON)
                    debugPrintln("Game created with game ID: \(game.gameID)")
                    game.fetchUsers() {
                        game.fetchResults() {
                            if let c = completionHandler {
                                c(game)
                            }
                        }
                    }
                    
                }
        }
    }
    
    /**
    GET api/Users/{userId}/getnewfriends?socialNetwork=FB
    */
    typealias TFBHUserFriendTuple = (fbFriends:[THUserFriend], thFriends:[THUserFriend])
    func fetchFriendListForUser(userId:Int, errorHandler:(NSError -> ())!, completionHandler: (TFBHUserFriendTuple -> ())!){
        let url = "\(THServerAPIBaseURL)/Users/\(userId)/getnewfriends?socialNetwork=FB"
        configureCompulsoryHeaders()
        debugPrintln("Fetching Facebook friends for user \(userId)...")
        
        let r = Alamofire.request(.GET, url, parameters: nil, encoding: JSONEncoding).responseJSON() {
            _, response, content, error in
            if let responseError = error {
                println(responseError)
                return
            }
            var friends: [THUserFriend] = []
            
            if let arr = content as? [AnyObject] {
                debugPrintln("Parsing \(arr.count) objects as THUserFriend...")
                for friendObj in arr {
                    let friendDictionary = friendObj as [String: AnyObject]
                    friends.append(THUserFriend(friendDTO: friendDictionary))
                }
                debugPrintln("Completely parsed objects as THUserFriend(s).")
            }
            var fbFrnds: [THUserFriend] = []
            var thFrnds: [THUserFriend] = []
            
            fbFrnds = friends.filter() { $0.userID == 0 }
            thFrnds = friends.filter() { $0.userID != 0 }
            
            debugPrintln("Successfully fetched \(friends.count) friend(s).")
            completionHandler((fbFrnds, thFrnds))
        }
        //        debugPrintln(r)
    }
    
    /*
    GET api/games/\(id)/details
    */
    func fetchGameByGameId(gameId:Int, completionHandler: (Game! -> ())!){
        let url = "\(THGameAPIBaseURL)/\(gameId)/details"
        configureCompulsoryHeaders()
        debugPrintln("Fetching game with game ID: \(gameId)...")
        
        
        let r = Alamofire.request(.GET, url, parameters: nil, encoding: JSONEncoding).responseJSON() {
            _, response, content, error in
            if error != nil {
                debugPrintln(error)
            }
            weak var wself = self
            if response?.statusCode == 200 {
                var sself = wself!
                let responseJSON = content as [String: AnyObject]
                //                println(responseJSON)
                let game = Game(gameDTO: responseJSON)
                debugPrintln("Game created with game ID: \(game.gameID)")
                
                game.fetchUsers() {
                    game.fetchResults() {
                        if let c = completionHandler {
                            c(game)
                        }
                    }
                }
            }
            
        }
        debugPrintln(r)
    }
    /**
    GET api/games/open
    */
    func fetchOpenChallenges(completionHandler: ([Game] -> ())!){
        let url = "\(THGameAPIBaseURL)/open"
        
        configureCompulsoryHeaders()
        debugPrintln("Fetching all open challenges for authenticated user...")
        weak var wself = self
        let r = Alamofire.request(.GET, url, parameters: nil, encoding: JSONEncoding).responseJSON() {
            _, response, content, error in
            var sself = wself!
            if error != nil {
                debugPrintln(error)
            }
            
            if let openChallengesDTOs = content as? [AnyObject] {
                if openChallengesDTOs.count == 0 {
                    debugPrintln("User has no open challenges.")
                    completionHandler([])
                } else {
//                    debugPrintln("Parsing \(openChallengesDTOs.count) objects as open challenges...")
                    var numberCompleted = 0
                    var total = openChallengesDTOs.count
                    var openChallenges: [Game] = []
                    
                    let fetchUserHandler: () -> () = {
                        numberCompleted++
                        if numberCompleted == total {
                            debugPrintln("Successfully fetched \(total) open challenge(s).")
                            if let handler = completionHandler {
                                handler(openChallenges)
                            }
                        }
                    }
                    
                    for openChallengeDTO in openChallengesDTOs as [[String: AnyObject]] {
                        let game = Game(compactGameDTO: openChallengeDTO)
                        
                        game.fetchUsers(){
                            openChallenges.append(game)
                            fetchUserHandler()
                        }
                    }
                    
                }
            }
        }
        //        debugPrintln(r)
    }
    
    /**
    GET api/games/taken
    */
    func fetchTakenChallenges(completionHandler: ([Game] -> ())!){
        let url = "\(THGameAPIBaseURL)/taken"
        
        configureCompulsoryHeaders()
        debugPrintln("Fetching all taken challenges for authenticated user...")
        weak var wself = self
        let r = Alamofire.request(.GET, url, parameters: nil, encoding: JSONEncoding).responseJSON() {
            _, response, content, error in
            var sself = wself!
            if error != nil {
                debugPrintln(error)
            }
            
            if let takenChallengesDTOs = content as? [AnyObject] {
                if takenChallengesDTOs.count == 0 {
                    debugPrintln("User has no taken challenges.")
                    completionHandler([])
                } else {
//                    debugPrintln("Parsing \(takenChallengesDTOs.count) objects as taken challenges...")
                    var numberCompleted = 0
                    var total = takenChallengesDTOs.count
                    var takenChallenges: [Game] = []
                    
                    let fetchUserHandler: () -> () = {
                        numberCompleted++
                        if numberCompleted == total {
                            debugPrintln("Successfully fetched \(total) taken challenge(s).")
                            if let handler = completionHandler {
                                handler(takenChallenges)
                            }
                        }
                    }
                    for takenChallengeDTO in takenChallengesDTOs as [[String: AnyObject]] {
                        let game = Game(compactGameDTO: takenChallengeDTO)
                        
                        var initiatorID: Int!
                        if let i: AnyObject = takenChallengeDTO["createdByUserId"]{
                            initiatorID = i as Int
                        }
                        
                        var opponentID: Int!
                        if let i: AnyObject = takenChallengeDTO["opponentUserId"]{
                            opponentID = i as Int
                        }
                        game.fetchUsers(){
                            takenChallenges.append(game)
                            fetchUserHandler()
                        }
                    }
                    
                    
                    //                    completionHandler([])
                }
            }
        }
        //        debugPrintln(r)
    }
    
    ///
    func createQuickGame(completionHandler: (Game! -> ())!){
                let fakeID = 2415
//        let fakeID = 617543
        createChallenge(numberOfQuestions: 7, opponentId: fakeID) {
            if let handler = completionHandler {
                handler($0)
            }
        }
    }
    
    /**
    POST api/games/postresults
    */
    func postGameResults(game:Game, highestCombo:UInt, noOfHintsUsed hints: UInt,currentScore:Int, questionResults:[QuestionResult], completionHandler:(Game -> ())!){
        let url = "\(THGameAPIBaseURL)/postResults"
        configureCompulsoryHeaders()
        debugPrintln("Posting results for game \(game.gameID)...")
        var resultSet:[[String:AnyObject]] = []
        for result in questionResults {
            var resultData:[String:AnyObject] = ["questionId" : result.questionId, "combo": highestCombo, "time" : result.timeTaken, "rawScore": result.rawScore, "noOfHintsUsed": hints]
            resultSet.append(resultData)
        }
        var param:[String: AnyObject] = ["gameId": game.gameID, "results": resultSet]
        weak var wself = self
        let r = Alamofire.request(.POST, url, parameters: param, encoding: JSONEncoding).responseJSON() {
            _, response, content, error in
            var sself = wself!
            if error != nil {
                debugPrintln(error)
            }
            
            game.fetchResults() {
                if let c = completionHandler {
                    c(game)
                }
            }
        }
        //                debugPrintln(r)
    }
    
    /**
    GET api/games/\(gameId)/results
    */
    typealias THGameResultsTuple = (challengerResult:GameResult?, opponentResult:GameResult?)
    func getResultForGame(gameId:Int, completionHandler:(THGameResultsTuple -> ())!){
        let url = "\(THGameAPIBaseURL)/\(gameId)/results"
        configureCompulsoryHeaders()
        debugPrintln("Fetching results for game \(gameId)...")
        weak var wself = self
        let r = Alamofire.request(.GET, url, parameters: nil, encoding: JSONEncoding).responseJSON() {
            _, response, content, error in
            var sself = wself!
            if error != nil {
                debugPrintln(error)
            }
            
            if let resultsDTO = content as? [String : AnyObject] {
                
                var challengerResult:GameResult?
                if let challengerResultDTO: AnyObject = resultsDTO["challenger"] {
                    debugPrintln("Parsing game initiator result..")
                    let dto = challengerResultDTO as [String : AnyObject]
                    challengerResult = GameResult(gameId:gameId, resultDTO: dto)
                }
                var opponentResult:GameResult?
                if let opponentResultDTO: AnyObject = resultsDTO["opponent"] {
                    debugPrintln("Parsing game opponent result..")
                    let dto = opponentResultDTO as [String : AnyObject]
                    opponentResult = GameResult(gameId:gameId, resultDTO: dto)
                }
                
                if let c = completionHandler{
                    c((challengerResult:challengerResult, opponentResult:opponentResult))
                }
            }
        }
        debugPrintln(r)
    }
    
    ///
    /// Logs out current session, removing credentials and user details stored in keychain or in device.
    ///
    func logout() {
        self.authenticatedUser = nil
        self.removeCredentials()
        EGOCache.globalCache().clearCache()
    }
    
    // MARK: Simple functions
    
    /**
    Fetch user with given user ID, handles with completion handler while fetches completely.
    
    :param: userId User ID to fetch
    :param: completionHandler Handles fetched user if succeed
    */
    func fetchUser(userId: Int, force:Bool = false, completionHandler: THUser! -> ()) {
        configureCompulsoryHeaders()
        let userCacheKey = "\(kTHUserCacheStoreKeyPrefix)\(userId)"
        if !force {
            let obj = EGOCache.globalCache().objectForKey(userCacheKey)
            if obj != nil {
                let user = obj as THUser
                completionHandler(user)
                return
            }
        }
        
        Alamofire.request(.GET, "\(THServerAPIBaseURL)/Users/\(userId)", parameters: nil, encoding: JSONEncoding).responseJSON() {
            _, response, content, error in
            if let responseError = error {
                println(responseError)
                return
            }
            if let profileDTODict = content as? [String: AnyObject] {
                var user = THUser(profileDTO: profileDTODict)
                EGOCache.globalCache().setObject(user, forKey: userCacheKey)
                completionHandler(user)
            }
        }
    }
    
    
    // MARK:- Class functions
    
    ///
    /// Fetch an image from a fully qualified URL String.
    ///
    /// :param: urlString Fully qualified URL String of the image to be fetched
    /// :param: progressHandler Refer to SDWebImageDownloaderProgressBlock
    /// :param: completionHandler process image if successfully downloaded.
    ///
    class func fetchImageFromURLString(urlString: String!, progressHandler: ((Int, Int) -> ())?, completionHandler:(UIImage!, NSError!) -> ()) {
        
        if urlString == nil {
            return
        }
        var fetchedImage: UIImage!
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: urlString), options: .CacheMemoryOnly, progress: progressHandler) {
            (image, error, cacheType, finished, url) -> () in
            if error != nil {
                println(error)
            }
            completionHandler(image, error)
        }
    }
    
    // MARK:- private functions
    
    func configureCompulsoryHeaders(){
        var headers = Alamofire.Manager.sharedInstance.defaultHeaders
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
        Alamofire.Manager.sharedInstance.defaultHeaders = headers
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
        if let accs = SSKeychain.accountsForService(kTHGameKeychainIdentifierKey) {
            for userData in accs {
                if let data = userData as? [String: String] {
                    SSKeychain.deletePasswordForService(kTHGameKeychainIdentifierKey, account: data["acct"])
                }
            }
            self.credentials = nil
        }
    }
    
    private func loadCredentials() {
        if let keychainAcc = SSKeychain.accountsForService(kTHGameKeychainIdentifierKey) {
            if keychainAcc.count == 0 {
                println("No credentials found")
            }
            
            for userData in keychainAcc {
                if let data = userData as? [String: String] {
                    let secret = SSKeychain.passwordForService(kTHGameKeychainIdentifierKey, account: kTHGameKeychainFacebookAccKey)
                    self.credentials = secret
                }
            }
            
        }
    }
    
    
    
}
