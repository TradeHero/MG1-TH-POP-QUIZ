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
            
            var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
            defaultHeaders.updateValue("2.4.0", forKey: "TH-Client-Version")
            defaultHeaders.updateValue("1", forKey: "TH-Client-Type")
            defaultHeaders.updateValue("en-GB", forKey: "TH-Language-Code")
            defaultHeaders.updateValue("2.4.0", forKey: "THPQ-Client-Version")
            defaultHeaders.updateValue("1", forKey: "THPQ-Client-Type")
            defaultHeaders.updateValue("en-GB", forKey: "THPQ-Language-Code")
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = defaultHeaders
            Singleton.instance.manager = Alamofire.Manager(configuration: configuration)
        }
        
        return Singleton.instance
    }
    
    var deviceToken: String {
        get {
            return _device_token
        }
        set {
            _device_token = newValue
        }
    }
    
    private var _device_token: String = ""
    
    private var manager: Alamofire.Manager!
    
    /// Authenticated user
    private var authenticatedUser: THUser!
    
    var user: THUser! {
        get {
            return authenticatedUser
        }
    }
    /// Credential dictionary (FB Token)
    var credentials: String!
    
    /// default JSON encoding
    let JSONEncoding = Alamofire.ParameterEncoding.JSON
    
    // MARK:- Methods
    
    /**
    Perform login with Facebook access token and completes operation by acquiring authenticated user session.
    
    :param: accessToken Facebook access token from active facebook session
    :param: loginSuccessHandler Takes a THUser and perform operation
    */
    func loginUserWithFacebookAuth(accessToken:String, loginSuccessHandler:(THUser -> ())!) {
        let param: [String: AnyObject] = ["clientType": 1, "clientVersion" : "2.4.0"]
        let auth = "\(THAuthFacebookPrefix) \(accessToken)"
        println(auth)
        weak var weakSelf = self
        let r = self.request(.POST,
            THServerAPIBaseURL + "/login",
            parameters: param,
            encoding: JSONEncoding,
            authentication: auth).responseJSON {
                _, response, content, error in
                var strongSelf = weakSelf!
                if let responseError = error {
                    println(responseError)
                    return
                }
                
                if response?.statusCode == 200 {
                    self.saveCredentials(accessToken)
                    let x = self.loadCredentials()
                    
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
//                debugPrintln(r)
    }
    
    /**
    Create challenge by specifying number of question, opponent ID, and handles completion with a game object.
    */
    func createChallenge(numberOfQuestions:Int = 7, opponentId:Int!, completionHandler: (Game! -> ())!) {
        var param:[String:AnyObject] = ["numberOfQuestions": numberOfQuestions]
        if let id = opponentId {
            debugPrintln("Creating challenge with user \(id) with \(numberOfQuestions) questions(s)")
            param.updateValue(id, forKey: "opponentId")
        } else {
            debugPrintln("Creating quick game with \(numberOfQuestions) questions(s)")
        }
        
        weak var wself = self
        let r = self.request(.POST, "\(THGameAPIBaseURL)/create", parameters: param, encoding: JSONEncoding, authentication:"\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
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
                    game.fetchUsers {
                        game.fetchResults {
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
    GET api/Users/{userId}/getnewfriends?socialNetwork=FB
    */
    typealias TFBHUserFriendTuple = (fbFriends:[THUserFriend], thFriends:[THUserFriend])
    func fetchFriendListForUser(userId:Int, errorHandler:(NSError -> ())!, completionHandler: (TFBHUserFriendTuple -> ())!){
        let url = "\(THServerAPIBaseURL)/Users/\(userId)/getnewfriends?socialNetwork=FB"
        debugPrintln("Fetching Facebook friends for user \(userId)...")
        
        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication:"\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
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
            
            fbFrnds = friends.filter { $0.userID == 0 }
            thFrnds = friends.filter { $0.userID != 0 }
            
            debugPrintln("Successfully fetched \(friends.count) friend(s).")
            completionHandler((fbFrnds, thFrnds))
        }
        //        debugPrintln(r)
    }
    
    /**
    GET api/games/open
    */
    func fetchOpenChallenges(completionHandler: ([Game] -> ())!){
        let url = "\(THGameAPIBaseURL)/open"
        
        debugPrintln("Fetching all open challenges for authenticated user...")
        weak var wself = self
        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication:"\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
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
                        
                        game.fetchUsers{
                            game.fetchResults {
                                openChallenges.append(game)
                                fetchUserHandler()
                            }
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
        
        debugPrintln("Fetching all taken challenges for authenticated user...")
        weak var wself = self
        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication:"\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
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
                        game.fetchUsers{
                            game.fetchResults {
                                takenChallenges.append(game)
                                fetchUserHandler()
                            }
                        }
                    }
                }
            }
        }
        //        debugPrintln(r)
    }
    
    /**
    GET api/games/theirturn
    */
    func fetchOpponentPendingChallenges(completionHandler: ([Game] -> ())!){
        let url = "\(THGameAPIBaseURL)/theirturn"
        
        debugPrintln("Fetching all opponent pending challenges for authenticated user...")
        weak var wself = self
        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication:"\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            _, response, content, error in
            var sself = wself!
            if error != nil {
                debugPrintln(error)
            }
            var pendingChallenges: [Game] = []
            if let pendingChallengesDTOs = content as? [AnyObject] {
                if pendingChallengesDTOs.count == 0 {
                    debugPrintln("User has no opponent pending challenges.")
                    completionHandler(pendingChallenges)
                } else {
                    //                    debugPrintln("Parsing \(takenChallengesDTOs.count) objects as taken challenges...")
                    var numberCompleted = 0
                    var total = pendingChallengesDTOs.count
                    
                    let fetchUserHandler: () -> () = {
                        numberCompleted++
                        if numberCompleted == total {
                            debugPrintln("Successfully fetched \(total) opponent pending challenge(s).")
                            if let handler = completionHandler {
                                handler(pendingChallenges)
                            }
                        }
                    }
                    for pendingChallengeDTO in pendingChallengesDTOs as [[String: AnyObject]] {
                        let game = Game(compactGameDTO: pendingChallengeDTO)
                        
                        var initiatorID: Int!
                        if let i: AnyObject = pendingChallengeDTO["createdByUserId"]{
                            initiatorID = i as Int
                        }
                        
                        var opponentID: Int!
                        if let i: AnyObject = pendingChallengeDTO["opponentUserId"]{
                            opponentID = i as Int
                        }
                        game.fetchUsers{
                            game.fetchResults {
                                pendingChallenges.append(game)
                                fetchUserHandler()
                            }
                        }
                    }
                    
                    
                    //                    completionHandler([])
                }
            }
        }
        //        debugPrintln(r)
    }

    /**
    GET api/games/unfinished
    */
    func fetchIncompleteChallenges(completionHandler: ([Game] -> ())!){
        let url = "\(THGameAPIBaseURL)/unfinished"
        
        debugPrintln("Fetching all incomplete challenges for authenticated user...")
        weak var wself = self
        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication:"\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            _, response, content, error in
            var sself = wself!
            if error != nil {
                debugPrintln(error)
            }
            var incompleteChallenges: [Game] = []
            if let incompleteChallengesDTOs = content as? [AnyObject] {
                if incompleteChallengesDTOs.count == 0 {
                    debugPrintln("User has no incomplete challenges.")
                    completionHandler(incompleteChallenges)
                } else {

                    var numberCompleted = 0
                    var total = incompleteChallengesDTOs.count
                    
                    let fetchUserHandler: () -> () = {
                        numberCompleted++
                        if numberCompleted == total {
                            debugPrintln("Successfully fetched \(total) incomplete challenge(s).")
                            if let handler = completionHandler {
                                handler(incompleteChallenges)
                            }
                        }
                    }
                    for incompleteChallengeDTO in incompleteChallengesDTOs as [[String: AnyObject]] {
                        let game = Game(compactGameDTO: incompleteChallengeDTO)
                        
                        var initiatorID: Int!
                        if let i: AnyObject = incompleteChallengeDTO["createdByUserId"]{
                            initiatorID = i as Int
                        }
                        
                        var opponentID: Int!
                        if let i: AnyObject = incompleteChallengeDTO["opponentUserId"]{
                            opponentID = i as Int
                        }
                        game.fetchUsers{
                            game.fetchResults {
                                incompleteChallenges.append(game)
                                fetchUserHandler()
                            }
                        }
                    }
                }
            }
        }
                debugPrintln(r)
    }

    /**
    GET api/games/closed
    */
    func fetchClosedChallenges(completionHandler: ([Game] -> ())!){
        let url = "\(THGameAPIBaseURL)/closed"
        
        debugPrintln("Fetching all closed challenges for authenticated user...")
        weak var wself = self
        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication:"\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            _, response, content, error in
            var sself = wself!
            if error != nil {
                debugPrintln(error)
            }
            
            if let closedChallengesDTOs = content as? [AnyObject] {
                if closedChallengesDTOs.count == 0 {
                    debugPrintln("User has no closed challenges.")
                    completionHandler([])
                } else {
                    var numberCompleted = 0
                    var total = closedChallengesDTOs.count
                    var closedChallenges: [Game] = []
                    
                    let fetchUserHandler: () -> () = {
                        numberCompleted++
                        if numberCompleted == total {
                            debugPrintln("Successfully fetched \(total) closed challenge(s).")
                            if let handler = completionHandler {
                                handler(closedChallenges)
                            }
                        }
                    }
                    for closedChallengeDTO in closedChallengesDTOs as [[String: AnyObject]] {
                        let game = Game(compactGameDTO: closedChallengeDTO)
                        
                        var initiatorID: Int!
                        if let i: AnyObject = closedChallengeDTO["createdByUserId"]{
                            initiatorID = i as Int
                        }
                        
                        var opponentID: Int!
                        if let i: AnyObject = closedChallengeDTO["opponentUserId"]{
                            opponentID = i as Int
                        }
                        game.fetchUsers{
                            game.fetchResults {
                                closedChallenges.append(game)
                                fetchUserHandler()
                            }
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
        
        createChallenge(numberOfQuestions: 7, opponentId: nil) {
            if let handler = completionHandler {
                handler($0)
            }
        }
    }
    
    /**
    POST api/games/postresults
    */
    func postGameResults(game:Game, highestCombo:Int, noOfHintsUsed hints: UInt,currentScore:Int, questionResults:[QuestionResult], completionHandler:(Game -> ())!){
        let url = "\(THGameAPIBaseURL)/postResults"
        
        debugPrintln("Posting results for game \(game.gameID)...")
        var resultSet:[[String:AnyObject]] = []
        for result in questionResults {
            var resultData:[String:AnyObject] = ["questionId" : result.questionId, "correctStreak": highestCombo, "time" : result.timeTaken, "rawScore": result.rawScore, "hintsUsed": hints]
            resultSet.append(resultData)
        }
        var param:[String: AnyObject] = ["gameId": game.gameID, "results": resultSet]
        weak var wself = self
        let r = self.request(.POST, url, parameters: param, encoding: JSONEncoding, authentication:"\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
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

        debugPrintln("Fetching results for game \(gameId)...")
        weak var wself = self
        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication:"\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            _, response, content, error in
            var sself = wself!
            if error != nil {
                debugPrintln(error)
            }
            
            if let resultsDTO = content as? [String : AnyObject] {
                let inner: AnyObject? = resultsDTO["result"]
                if let innerResultDTO = inner as? [String : AnyObject] {
                    var challengerResult:GameResult?
                    if let challengerResultDTO: AnyObject = innerResultDTO["challenger"] {
                        debugPrintln("Parsing game initiator result..")
                        let dto = challengerResultDTO as [String : AnyObject]
                        challengerResult = GameResult(gameId:gameId, resultDTO: dto)
                    }
                    var opponentResult:GameResult?
                    if let opponentResultDTO: AnyObject = innerResultDTO["opponent"] {
                        debugPrintln("Parsing game opponent result..")
                        let dto = opponentResultDTO as [String : AnyObject]
                        opponentResult = GameResult(gameId:gameId, resultDTO: dto)
                    }
                    
                    if let c = completionHandler{
                        c((challengerResult:challengerResult, opponentResult:opponentResult))
                    }
                }
            }
        }
//        debugPrintln(r)
    }
    
    ///MARK:- Game profile
    
    /**
    POST api/games/?
    */
    func updateInGameName(newName: String, completionHandler:()->()){
//        let url = "\(THGameAPIBaseURL)/??"
//        configureCompulsoryHeaders()
//        
//        
//        weak var wself = self
//        let r = Alamofire.request(.POST, url, parameters: ["ign" : newName], encoding: JSONEncoding).responseJSON {
//            _, response, content, error in
//            if let sself = wself {
//                sself.updateUser(sself.authenticatedUser) {
//                    sself.authenticatedUser = $0
//                }
//            }
//        }
    }
    
    func fetchStaffList(completionHandler:[StaffUser]->()){
        var staffArr = [StaffUser]()
        var numberCompleted = 0
        let fetchUserHandler: () -> () = {
            numberCompleted++
            if numberCompleted == staffs_g.count {
                staffArr.sort {
                    $0.userId < $1.userId
                }
                debugPrintln("Successfully fetched \(numberCompleted) staffs.")
                    completionHandler(staffArr)
            }
        }

        for staff in staffs_g {
            self.fetchUser(staff.id, force: false) {
                $0.displayName = staff.name
                staffArr.append(StaffUser(user: $0, funnyName: staff.funnyName))
                fetchUserHandler()
            }
        }
    }
    
    ///
    /// Logs out current session, removing credentials and user details stored in keychain or in device.
    ///
    func logout() {
        self.authenticatedUser = nil
        self.removeCredentials()
        EGOCache.globalCache().clearCache()
        FBSession.activeSession().closeAndClearTokenInformation()
        NSNotificationCenter.defaultCenter().postNotificationName(kTHGameLogoutNotificationKey, object: self, userInfo:nil)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kTHPushNotificationOnKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kTHSoundEffectValueKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kTHBackgroundMusicValueKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kTHVibrationEffectOnKey)
    }
    
    // MARK: Simple functions
    
    /**
    Fetch user with given user ID, handles with completion handler while fetches completely.
    
    :param: userId User ID to fetch
    :param: completionHandler Handles fetched user if succeed
    */
    func fetchUser(userId: Int, force:Bool = false, completionHandler: THUser! -> ()) {
        
        if !force {
            if let user = THCache.getUserFromCache(userId) {
                completionHandler(user)
                return
            }
        }
        
       let r = self.request(.GET, "\(THServerAPIBaseURL)/Users/\(userId)", parameters: nil, encoding: JSONEncoding, authentication:"\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            _, response, content, error in
            if let responseError = error {
                println(responseError)
                return
            }
            if let profileDTODict = content as? [String: AnyObject] {
                var user = THUser(profileDTO: profileDTODict)
                THCache.saveUserToCache(user, userId: userId)
                completionHandler(user)
            }
        }
    }
    
    func refreshUser(user:THUser, completionHandler: THUser -> ()){
        self.fetchUser(user.userId, force: true) {
            if let u = $0 {
                completionHandler(user)
            }
        }
    }
    
    /*
    GET api/games/\(id)/details
    */
    func fetchGame(gameId:Int, force:Bool = false, completionHandler: (Game! -> ())!){
        let url = "\(THGameAPIBaseURL)/\(gameId)/details"
        debugPrintln("Fetching game with game ID: \(gameId)...")
        
        if !force {
            if let game = THCache.getGameFromCache(gameId) {
                completionHandler(game)
                return
            }
        }
        
        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication: generateAuthorisationFromKeychain() ?? "").responseJSON {
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
                
                game.fetchUsers {
                    game.fetchResults {
                        if let c = completionHandler {
                            c(game)
                        }
                    }
                }
            }
            
        }
        //        debugPrintln(r)
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
    
    private func loadCredentials() -> String? {
        if let keychainAcc = SSKeychain.accountsForService(kTHGameKeychainIdentifierKey) {
            if keychainAcc.count == 0 {
                println("No credentials found")
            }
            
            for userData in keychainAcc {
                if let data = userData as? [String: AnyObject] {
                    let secret = SSKeychain.passwordForService(kTHGameKeychainIdentifierKey, account: kTHGameKeychainFacebookAccKey)
                    self.credentials = secret
                    return secret
                }
            }
            
        }
        return nil
    }
    
    private func request(method: Alamofire.Method, _ URLString: Alamofire.URLStringConvertible, parameters: [String: AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, authentication: String) -> Request {
        return manager.request(encoding.encode(authenticatedURLRequest(method, URLString: URLString, authentication: authentication), parameters: parameters).0)
    }

    private func authenticatedURLRequest(method: Alamofire.Method, URLString: Alamofire.URLStringConvertible, authentication: String) -> NSURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString.URLString))
        mutableURLRequest.HTTPMethod = method.toRaw()
        mutableURLRequest.setValue(authentication, forHTTPHeaderField: "Authorization")
        
        return mutableURLRequest
    }
}
