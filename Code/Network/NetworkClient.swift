//
//  NetworkClient.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Alamofire
import JGProgressHUD
import SDWebImage
import EGOCache
import SSKeychain
import FacebookSDK
import Argo

class NetworkClient {

    // MARK:- Variables

    /// Singleton network client
    class var sharedClient: NetworkClient {

        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var instance: NetworkClient!
        }

        dispatch_once(&Singleton.onceToken) {
            Singleton.instance = NetworkClient()
            Singleton.instance.loadCredentials()
            Singleton.instance.loadDeviceToken()
            var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
            defaultHeaders.updateValue("3.1.0", forKey: "TH-Client-Version")
            defaultHeaders.updateValue("1", forKey: "TH-Client-Type")
            defaultHeaders.updateValue("en-GB", forKey: "TH-Language-Code")
            defaultHeaders.updateValue("1.5.0", forKey: "THPQ-Client-Version")
            defaultHeaders.updateValue("1", forKey: "THPQ-Client-Type")
            defaultHeaders.updateValue("en-GB", forKey: "THPQ-Language-Code")
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = defaultHeaders
//            configuration.timeoutIntervalForRequest = 10
            Singleton.instance.manager = Alamofire.Manager(configuration: configuration)


        }

        return Singleton.instance
    }

    var _device_token: String!

    private var manager: Alamofire.Manager!

    /// Authenticated user
    private var authenticatedUser: User!

    var user: User! {
        get {
            return authenticatedUser
        }
    }
    /// Credential dictionary (FB Token)
    var credentials: String!

    /// default JSON encoding
    let JSONEncoding = Alamofire.ParameterEncoding.JSON

    var userShareEnabled = false

    // MARK:- Methods

    /**
    Perform login with Facebook access token and completes operation by acquiring authenticated user session.
    
    :param: accessToken Facebook access token from active facebook session
    :param: loginSuccessHandler Takes a THUser and perform operation
    */
    func loginUserWithFacebookAuth(accessToken: String, loginSuccessHandler: (User -> ())!, errorHandler: NSError -> ()) {
        var param: [String:AnyObject] = ["clientType": 1, "clientVersion": "3.1.0", "facebook_access_token": accessToken]
        let auth = "\(THAuthFacebookPrefix) \(accessToken)"

        if _device_token != nil {
            param.updateValue(_device_token, forKey: "deviceToken")
        }

        let r = self.request(.POST,
                THServerAPIBaseURL + "/signupAndLogin",
                parameters: param,
                encoding: JSONEncoding,
                authentication: auth).responseJSON {
            [unowned self] _, response, content, error in
            if let responseError = error {
                println(responseError)
                errorHandler(responseError)
                return
            }

            if response?.statusCode == 200 {
                self.saveCredentials(accessToken)

                let responseJSON = content as [String:AnyObject]
                let profileDTOPart: AnyObject? = responseJSON["profileDTO"]

                if let profileDTODict = profileDTOPart as? [String:AnyObject] {
                    var loginUser = User.decode(JSONValue.parse(profileDTODict))!
                    println("Signed in as \(loginUser)")
                    self.authenticatedUser = loginUser
                    let userInfo = ["user": loginUser.dictionaryRepresentation]
                    NSNotificationCenter.defaultCenter().postNotificationName(kTHGameLoginSuccessfulNotificationKey, object: self, userInfo: userInfo)
                    loginSuccessHandler(loginUser)
                }
            } else if response?.statusCode == 417 {
                let err = NSError(domain: "com.mymanisku.TH-PopQuiz", code: 417, userInfo: ["message": "Expired access token"])
                errorHandler(err)
            } else {
                let err = NSError(domain: "com.mymanisku.TH-PopQuiz", code: response!.statusCode, userInfo: [NSLocalizedDescriptionKey: "\(content)"])
                errorHandler(err)
            }
        }
        debugPrintln(r)
    }

    /**
    Create challenge by specifying number of question, opponent ID, and handles completion with a game object.
    */
    func createChallenge(numberOfQuestions: Int = 7, opponentId: Int!, errorHandler: NSError -> (), completionHandler: Game -> ()) {
        var param: [String:AnyObject] = ["numberOfQuestions": numberOfQuestions]
        if let id = opponentId {
            debugPrintln("Creating challenge with user \(id) with \(numberOfQuestions) questions(s)")
            param.updateValue(id, forKey: "opponentId")
        } else {
            debugPrintln("Creating quick game with \(numberOfQuestions) questions(s)")
        }


        let r = self.request(.POST, "\(THGameAPIBaseURL)/create", parameters: param, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            [unowned self] _, response, content, error in
            if let responseError = error {
                println(responseError)
                return
            }

            if response?.statusCode == 200 {
                if let responseJSON = content as? [String:AnyObject] {
                    var game = Game.decode(JSONValue.parse(responseJSON))!
                    debugPrintln("Game created with game ID: \(game.id)")
                    completionHandler(game)
                }
            }
        }
        debugPrintln(r)
    }

    /**
    GET api/Users/{userId}/getnewfriends?socialNetwork=FB
    */
    typealias TFBHUserFriendTuple = (facebookFriends:[UserFriend], tradeheroFriends:[UserFriend])

    func fetchFriendListForUser(userId: Int, errorHandler: NSError -> (), completionHandler: TFBHUserFriendTuple -> ()) {
        let url = "\(THServerAPIBaseURL)/users/\(userId)/getnewfriends?socialNetwork=FB"
        debugPrintln("Fetching Facebook friends for user \(userId)...")


        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            [unowned self] _, response, content, error in
            if let e = error {
                errorHandler(e)
            }
            var friends: [UserFriend] = []

            if let arr = content as? [AnyObject] {
                debugPrintln("Parsing \(arr.count) objects as THUserFriend...")
                for friendObj in arr {
                    friends.append(UserFriend.decode(JSONValue.parse(friendObj))!)
                }
                debugPrintln("Completely parsed objects as User Friend(s).")
            }
            var fbFrnds: [UserFriend] = []
            var thFrnds: [UserFriend] = []

            fbFrnds = friends.filter {
                $0.thUserId == 0
            }
            thFrnds = friends.filter {
                $0.thUserId != 0
            }
            debugPrintln("Successfully fetched \(friends.count) friend(s).")
            completionHandler((fbFrnds, thFrnds))
        }

        //debugPrintln(r)
    }

    func getRandomFBFriendsForUser(numberOfUsers count: Int, forUser userId: Int, errorHandler: NSError -> (), completionHandler: [UserFriend] -> ()) {
        let url = "\(THServerAPIBaseURL)/users/\(userId)/getnewfriends?socialNetwork=FB&count=100"
        debugPrintln("Fetching Facebook friends for user \(userId)...")

        if THCache.objectExistForCacheKey(kTHRandomFBFriendsCacheStoreKey) {
            var friends = THCache.getRandomFBFriendsFromCache()
            friends.shuffle()
            var filteredFriends = [UserFriend]()
            for f in friends {
                if filteredFriends.count == count {
                    break
                }
                filteredFriends.append(f)
            }
            completionHandler(filteredFriends)
            return
        }

        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            _, response, content, error in
            if let responseError = error {
                println(responseError)
                return
            }

            var friends: [UserFriend] = []
            if var arr = content as? [AnyObject] {
                arr.shuffle()
                debugPrintln("Parsing \(arr.count) objects as THUserFriend...")

                for friendObj in arr {
                    let friendDictionary = friendObj as [String:AnyObject]
                    if let uID: AnyObject = friendDictionary["thUserId"] {
                        let uIDInt = uID as Int
                        if uIDInt != 0 {
                            if let uf = UserFriend.decode(JSONValue.parse(friendDictionary)){
                                friends.append(uf)
                            }
                        }
                    }
                }
                debugPrintln("Completely parsed \(friends.count) objects as THUserFriend(s).")
                THCache.saveRandomFBFriends(friends)
                var filteredFriends = [UserFriend]()
                for f in friends {
                    if filteredFriends.count == count {
                        break
                    }
                    filteredFriends.append(f)
                }
                completionHandler(filteredFriends)
            }

        }
        debugPrintln(r)


    }

    /**
    GET api/games/home
    */
    typealias THMGChallengesTuple = (unfinishedChallenges:[Game], openChallenges:[Game], opponentPendingChallenges:[Game])

    func fetchAllChallenges(errorHandler: NSError -> (), completionHandler: THMGChallengesTuple -> ()) {
        let url = "\(THGameAPIBaseURL)/home"

        debugPrintln("Fetching all all (open, unfinished, opponent pending) challenges for authenticated user...")
        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            [unowned self] _, response, content, error in

            if let e = error {
                errorHandler(e)
            }

            var openChallenges = [Game]()
            var unfinishedChallenges = [Game]()
            var opponentPendingChallenges = [Game]()

            var count = 0
            let intermediateHandler: () -> () = {
                count++
                if count == 3 {
                    completionHandler((unfinishedChallenges, openChallenges, opponentPendingChallenges))
                }
            }

            if let allChallengeDtos = content as? [String:AnyObject] {
                //parse open challenges
                if let openChallengeDtos = allChallengeDtos["openChallenges"] as? [AnyObject] {
                    println("Parsing \(openChallengeDtos.count) open challenges.")
                    for dto in openChallengeDtos {
                        var game = Game.decode(JSONValue.parse(dto))!
                        openChallenges.append(game)
                    }
                    println("Parsed \(openChallenges.count) open challenges.")
                }

                //parse unfinished challenges
                if let unfinishedChallengeDtos = allChallengeDtos["unfinishedChallenges"] as? [AnyObject] {
                    println("Parsing \(unfinishedChallengeDtos.count) unfinished challenges.")
                    for dto in unfinishedChallengeDtos {
                        var game = Game.decode(JSONValue.parse(dto))!
                        unfinishedChallenges.append(game)
                    }
                    println("Parsed \(unfinishedChallenges.count) unfinished challenges.")
                }

                //parse opponent pending challenges
                if let opponentPendingChallengeDtos = allChallengeDtos["opponnentPendingChallenges"] as? [AnyObject] {
                    println("Parsing \(opponentPendingChallengeDtos.count) opponent pending challenges.")
                    for dto in opponentPendingChallengeDtos {
                        var game = Game.decode(JSONValue.parse(dto))!
                        opponentPendingChallenges.append(game)
                    }
                    println("Parsed \(opponentPendingChallenges.count) opponent pending challenges.")
                }

                completionHandler((unfinishedChallenges: unfinishedChallenges, openChallenges: openChallenges, opponentPendingChallenges: opponentPendingChallenges))
            }
        }
        //debugPrintln(r)
    }

    /**
    GET api/games/closed
    */
    func fetchClosedChallenges(errorHandler: NSError -> (), completionHandler: [Game] -> ()) {
        let url = "\(THGameAPIBaseURL)/closed"

        debugPrintln("Fetching all closed challenges for authenticated user...")
        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            [unowned self] _, response, content, error in

            if let e = error {
                errorHandler(e)
            }
            var closedChallenges = [Game]()

            if let closedChallengesDTOs = content as? [AnyObject] {
                println("Parsing \(closedChallenges.count) closed challenges.")
                for dto in closedChallengesDTOs {
                    var game = Game.decode(JSONValue.parse(dto))!
                    closedChallenges.append(game)
                }
                println("Parsed \(closedChallenges.count) closed challenges.")
            }
            completionHandler(closedChallenges)
        }
        //        debugPrintln(r)
    }


    ///
    func createQuickGame(errorHandler: NSError -> (), completionHandler: Game -> ()) {
        self.createChallenge(numberOfQuestions: 7, opponentId: nil, errorHandler: errorHandler) {
            completionHandler($0)
        }
    }

    /**
    POST api/games/postresults
    */
    func postGameResults(game: Game, highestCombo: Int, noOfHintsUsed hints: UInt, currentScore: Int, questionResults: [QuestionResult], errorHandler: NSError -> (), completionHandler: Game -> ()) {
        let url = "\(THGameAPIBaseURL)/postResults"

        debugPrintln("Posting results for game \(game.id)...")

        var resultSet:[[String:AnyObject]] = questionResults.map {
             return ["questionId": $0.questionId, "time": $0.timeTaken, "rawScore": $0.rawScore]
        }
        
        var param: [String:AnyObject] = ["gameId": game.id, "results": resultSet, "correctStreak": highestCombo, "hintsUsed": hints]

        let r = self.request(.POST, url, parameters: param, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            [unowned self] _, response, content, error in

            if let e = error {
                errorHandler(e)
            }

            if let gameResults = content as? [String:AnyObject] {
                if let challengerResultDTO = gameResults["challengerResult"] as? [String:AnyObject] {
                    game.challengerResult = GameResult.decode(JSONValue.parse(challengerResultDTO))
                }

                if let opponentResultDTO = gameResults["opponentResult"] as? [String:AnyObject] {
                    game.opponentResult = GameResult.decode(JSONValue.parse(opponentResultDTO))
                }

                completionHandler(game)
            }
        }
    }

    /**
    GET api/games/\(gameId)/results
    */
    typealias THGameResultsTuple = (challengerResult:GameResult?, opponentResult:GameResult?)

    func getResultForGame(gameId: Int, errorHandler: NSError -> (), completionHandler: THGameResultsTuple -> ()) {
        let url = "\(THGameAPIBaseURL)/\(gameId)/results"

        debugPrintln("Fetching results for game \(gameId)...")

        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            [unowned self] _, response, content, error in
            if let e = error {
                errorHandler(e)
            }

            var challengerResult: GameResult?
            var opponentResult: GameResult?

            if let resultsDTO = content as? [String:AnyObject] {

                if let challengerResultDTO = resultsDTO["challengerResult"] as? [String:AnyObject] {
                    challengerResult = GameResult.decode(JSONValue.parse(challengerResultDTO))
                }

                if let opponentResultDTO = resultsDTO["opponentResult"] as? [String:AnyObject] {
                    opponentResult = GameResult.decode(JSONValue.parse(opponentResultDTO))
                }

                completionHandler((challengerResult: challengerResult, opponentResult: opponentResult))
            }
        }

        //debugPrintln(r)
    }


    func fetchStaffList(progressHandler: Float -> (), errorHandler: NSError -> (), completionHandler: [StaffUser] -> ()) {
        let url = "\(THServerAPIBaseURL)/users/internal?mgTestSet=true"
        debugPrintln("Fetching staff users..")

        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            [unowned self] _, response, content, error in
            if let e = error {
                errorHandler(e)
            }
            var staffArr = [StaffUser]()
            println(content)
            if let staffList = content as? [AnyObject] {
                debugPrintln("Parsing \(staffList.count) staff users..")
                for staffData in staffList {
                    let staffUserDTO = staffData as [String:AnyObject]
                    let user = User.decode(JSONValue.parse(staffUserDTO))!
                    for staffinfo in staffs_g {
                        if staffinfo.id == user.userId {
                            staffArr.append(StaffUser(user: user, funnyName: staffinfo.funnyName))
                            break
                        }
                    }
                }
                staffArr.sort {
                    $0.userId < $1.userId
                }
                debugPrintln("Successfully parsed \(staffArr.count) staffs.")
                completionHandler(staffArr)
            }
        }
        debugPrintln(r)
    }


    // MARK: Simple functions

    func updateDeviceToken(deviceToken: String, errorHandler: NSError -> (), completionHandler: () -> ()) {
        let url = "\(THServerAPIBaseURL)/updateDevice"
        debugPrintln("Device token changed, updating device token..")

        let param = ["deviceToken": deviceToken]
        if let auth = generateAuthorisationFromKeychain() {
            let r = self.request(.POST, url, parameters: param, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(auth)").responseJSON {
                [unowned self] _, response, content, error in
                if let e = error {
                    debugPrintln("Device token update failure.")
                    errorHandler(e)
                }

                debugPrintln("Device token updated successfully")
                if let c: AnyObject = content {
//                println(c)
                }

            }

            debugPrintln(r)
        }
    }
    ///
    /// Logs out current session, removing credentials and user details stored in keychain or in device.
    ///
    func logout() {
        self.authenticatedUser = nil
        self.closeAndClearKeychainInformation()
        EGOCache.globalCache().clearCache()
//        FBSession.activeSession().closeAndClearTokenInformation()
        NSNotificationCenter.defaultCenter().postNotificationName(kTHGameLogoutNotificationKey, object: self, userInfo: nil)
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
    func fetchUser(userId: Int, force: Bool = false, errorHandler: NSError -> (), completionHandler: User! -> ()) {

        if !force {
            if let user = THCache.getCachedUser(userId) {
                completionHandler(user)
                return
            }
        }

        let r = self.request(.GET, "\(THServerAPIBaseURL)/Users/\(userId)", parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            _, response, content, error in
            if let e = error {
                errorHandler(e)
                return
            }
            if let profileDTODict = content as? [String:AnyObject] {
                var user = User.decode(JSONValue.parse(profileDTODict))!
                THCache.cacheUser(user)
                completionHandler(user)
            }
        }
    }

    func refreshUser(user: User, completionHandler: User -> ()) {
        self.fetchUser(user.userId, force: true, errorHandler: {
            error in
            debugPrintln(error)
        }) {
            if let u = $0 {
                completionHandler(user)
            }
        }
    }

    /*
    GET api/games/\(id)/details
    */
    func fetchGame(gameId: Int, force: Bool = false, errorHandler: NSError -> (), completionHandler: Game -> ()) {
        let url = "\(THGameAPIBaseURL)/\(gameId)/details"
        debugPrintln("Fetching game with game ID: \(gameId)...")

        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            [unowned self] _, response, content, error in
            if let e = error {
                errorHandler(e)
            }

            if response?.statusCode == 200 {
                if let responseJSON = content as? [String:AnyObject] {
                    var game = Game.decode(JSONValue.parse(responseJSON))!
                    debugPrintln("Game created with game ID: \(game.id)")
                    completionHandler(game)
                }
            }

        }
        debugPrintln(r)
    }


    func pushNotificationToDevice(deviceTokens: [String], alertMessage: String?, completionHandler: () -> ()) {
        if deviceTokens.count == 0 {
            debugPrintln("No device token, fail sending push notification")
            completionHandler()
            return
        }

        var appKey = "zH67PxmUQBCrerb3i9WhMQ"
        var appMasterPW = "ytXzvUeJSnGePt4WQVDkSA"

        switch kTHGamesServerMode {
        case .Staging:
            appKey = "zH67PxmUQBCrerb3i9WhMQ"
            appMasterPW = "ytXzvUeJSnGePt4WQVDkSA"
        case .Prod:
            appKey = "4TqEKTVwRUWCc4xcxfvIBg"
            appMasterPW = "F59gvDjdRpWt9PmcDRcjuQ"
        }

        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://go.urbanairship.com/api/push/".URLString)!)
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue("application/vnd.urbanairship+json; version=3;", forHTTPHeaderField: "Accept")

        var deviceTokenArray = [[String: String]]()
        for d in deviceTokens {
            deviceTokenArray.append(["device_token": d])
        }


        var iosFields = [String: AnyObject]()
        if let a = alertMessage {
            iosFields.updateValue(a, forKey: "alert")
            iosFields.updateValue("notification.caf", forKey: "sound")
            iosFields.updateValue(1, forKey: "badge")
        }
        var notificationDict = ["ios": iosFields, "android": ["alert": "hello"]]

        let data: [String:AnyObject] = ["audience": ["OR": deviceTokenArray], "notification": notificationDict, "device_types": ["ios"]]
        let r = self.manager.request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: data).0).authenticate(user: appKey, password: appMasterPW).responseJSON {
            (_, response, data, error) -> Void in
            if let err = error {
                debugPrintln(err)
            }
            if let d: AnyObject = data {
                debugPrintln(d)
            }

        }
        debugPrintln(r)
        completionHandler()
    }

    /**
        GET api/users/
    */
    func fetchUserDeviceTokens(id: Int, completionHandler: [String] -> ()) {
        let url = "\(THServerAPIBaseURL)/users/\(id)/token?deviceType=1"
        debugPrintln("Fetching device token with user ID: \(id)...")

        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            _, response, content, error in
            if let data: AnyObject = content {
                if let tokens = data as? [String] {
                    completionHandler(tokens)
                } else {
                    completionHandler([])
                }
            } else {
                completionHandler([])
            }
        }

        debugPrintln(r)
    }

    func sendPushNotification(targetUserId: Int, message: String?, completionHandler: () -> ()) {
        self.fetchUserDeviceTokens(targetUserId) {
            [unowned self] in
            self.pushNotificationToDevice($0, alertMessage: message, completionHandler: completionHandler)
        }
    }

    func nudgeGameUser(game: Game, completionHandler: () -> ()) {
        var url = "\(THGameAPIBaseURL)/\(game.id)/nudge"
        if kFaceBookShare {
            url = "\(url)?share=true"
        }

        let r = self.request(.GET, url, parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            [unowned self] _, response, content, error in
            if let e = error {
                debugPrintln(error)
            }

            completionHandler()
        }

        debugPrintln(r)
    }

    //MARK: Debug Items

    /**
    Fetch all static questions
    
    :param: userId User ID to fetch
    :param: completionHandler Handles fetched user if succeed
    */
    func fetchStaticQuestions(errorHandler: NSError -> (), completionHandler: [Question] -> ()) {
        if (!isInternalUser(self.authenticatedUser)) {
            errorHandler(NSError(domain: "com.mymanisku.THPopQuiz", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Non-internal user attempted retrieval"]))
        }

        let r = self.request(.GET, "\(THGameAPIBaseURL)/debugStatic", parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            _, response, content, error in
            if let e = error {
                errorHandler(e)
                return
            }
            var questions = [Question]()
            if let d = content as? [AnyObject] {
                
                questions = d.map{
                    return Question.decode(JSONValue.parse($0))!
                }

            }
            completionHandler(questions)
        }
        debugPrintln(r)
    }

    /**
    Fetch all static questions
    
    
    :param: completionHandler Handles fetched user if succeed
    */
    func fetchImageQuestions(errorHandler: NSError -> (), completionHandler: [Question] -> ()) {
        if (!isInternalUser(self.authenticatedUser)) {
            errorHandler(NSError(domain: "com.mymanisku.THPopQuiz", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Non-internal user attempted retrieval"]))
        }

        let r = self.request(.GET, "\(THGameAPIBaseURL)/debugImage", parameters: nil, encoding: JSONEncoding, authentication: "\(THAuthFacebookPrefix) \(generateAuthorisationFromKeychain()!)").responseJSON {
            _, response, content, error in
            if let e = error {
                errorHandler(e)
                return
            }
            var questions = [Question]()
            if let d = content as? [AnyObject] {
                for rawQuestion in d {
                    if let question = Question.decode(JSONValue.parse(rawQuestion)) {
                        questions.append(question)
                    }
                }

            }
            completionHandler(questions)
        }
        debugPrintln(r)
    }



    // MARK:- Class functions

    ///
    /// Fetch an image from a fully qualified URL String.
    ///
    /// :param: urlString Fully qualified URL String of the image to be fetched
    /// :param: progressHandler Refer to SDWebImageDownloaderProgressBlock
    /// :param: completionHandler process image if successfully downloaded.
    ///
    class func fetchImageFromURLString(urlString: String!, progressHandler: ((Int, Int) -> ())?, completionHandler: (UIImage!, NSError!) -> ()) {

        if urlString == nil {
            return
        }
        var fetchedImage: UIImage!

        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: urlString), options: .CacheMemoryOnly, progress: progressHandler) {
            (image, error, cacheType, finished, url) -> () in
            if error != nil {
                debugPrintln(error)
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
    private func generateBasicAuthHTTPHeader(username: String, password: String) -> String {
        return "Basic " + "\(username):\(password)".encodeToBase64Encoding()
    }

    ///
    /// Save credentials to system keychain for auto-login access.
    ///
    /// :param: username Log In ID
    /// :param: password Log In password
    ///
    private func saveCredentials(credentialString: String) {

        SSKeychain.setPassword("\(credentialString)", forService: kTHGameKeychainIdentifierKey, account: kTHGameKeychainFacebookAccountKey)

        self.credentials = credentialString
    }

    ///
    /// Remove completely credentials from system.
    ///
    private func closeAndClearKeychainInformation() {
        if let accs = SSKeychain.accountsForService(kTHGameKeychainIdentifierKey) {
            for userData in accs {
                if let data = userData as? [String:AnyObject] {
                    if let acct: AnyObject? = data["acct"] {
                        SSKeychain.deletePasswordForService(kTHGameKeychainIdentifierKey, account: acct as String)
                    }
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
                if let data = userData as? [String:AnyObject] {
                    let secret = SSKeychain.passwordForService(kTHGameKeychainIdentifierKey, account: kTHGameKeychainFacebookAccountKey)
                    self.credentials = secret
                    return secret
                }
            }

        }
        return nil
    }

    private func saveDeviceToken(token: String) {
        SSKeychain.setPassword("\(token)", forService: kTHGameKeychainIdentifierKey, account: kTHGameKeychainDeviceTokenKey)
    }

    private func loadDeviceToken() -> String? {
        if let keychainAcc = SSKeychain.accountsForService(kTHGameKeychainIdentifierKey) {
            if keychainAcc.count == 0 {
                println("No credentials found")
            }

            for userData in keychainAcc {
                if let data = userData as? [String:AnyObject] {
                    let secret = SSKeychain.passwordForService(kTHGameKeychainIdentifierKey, account: kTHGameKeychainDeviceTokenKey)
                    self._device_token = secret
                    return secret
                }
            }
        }
        return nil
    }

    private func request(method: Alamofire.Method, _ URLString: Alamofire.URLStringConvertible, parameters: [String:AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, authentication: String) -> Request {
        return manager.request(encoding.encode(authenticatedURLRequest(method, URLString: URLString, authentication: authentication), parameters: parameters).0)
    }

    private func authenticatedURLRequest(method: Alamofire.Method, URLString: Alamofire.URLStringConvertible, authentication: String) -> NSURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString.URLString)!)
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.setValue(authentication, forHTTPHeaderField: "Authorization")

        return mutableURLRequest
    }
}
