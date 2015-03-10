//
//  GameDTO.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 6/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import Argo
import Runes

class GameDTO: JSONDecodable, DebugPrintable, Equatable, DictionaryRepresentation {
    
    let id: Int
    let challenger: User
    let opponentUser: User
    let rejectedByOpponent: Bool
    let expired: Bool
    let questionSet: [QuestionDTO]
    var challengerResult: GameResultDTO?
    var opponentResult: GameResultDTO?
    let selfUser: User
    let awayUser: User
    var lastNudgedOpponentAt: NSDate!
    var createdAt: NSDate!
    
    var isGameCompletedByChallenger : Bool {
        return challengerResult != nil
    }
    
    var isGameCompletedByOpponent : Bool {
        return challengerResult != nil
    }
    
    var isGameCompletedByBothPlayer: Bool {
        return isGameCompletedByChallenger && isGameCompletedByOpponent
    }


    var completedAt: NSDate! {
        if isGameCompletedByBothPlayer {
            let date1 = challengerResult!.submittedAt
            let date2 = opponentResult!.submittedAt
            if date1.compare(date2) == .OrderedAscending {
                return date2
            } else {
                return date1
            }
        }
        return nil
    }

    class func decode(j: JSONValue) -> GameDTO? {
        return self.create
                <^> j <| "id"
                <*> j <| "challenger"
                <*> j <| "createdAtUtc"
                <*> j <| "opponent"
                <*> j <|| "questionSet"
                <*> j <|? "challengerResult"
                <*> j <|? "opponentResult"
                <*> j <| "rejectedByOpponent"
                <*> j <| "expired"
    }

    init(id: Int, challenger: User, opponentUser: User, rejectedByOpponent: Bool, expired: Bool, questionSet: [QuestionDTO], challengerResult: GameResultDTO?, opponentResult: GameResultDTO?, createdAt: NSDate!){
        self.id = id
        self.challenger = challenger
        self.opponentUser = opponentUser
        self.rejectedByOpponent = rejectedByOpponent
        self.expired = expired
        self.questionSet = questionSet
        self.challengerResult = challengerResult
        self.opponentResult = opponentResult
        
        var selfIsCreator = challenger.userId == NetworkClient.sharedClient.user.userId
        
        self.selfUser = selfIsCreator ? challenger : opponentUser
        self.awayUser = selfIsCreator ? opponentUser : challenger
        self.createdAt = createdAt
    }

    class func create(id: Int)(challenger: User)(createdAtUtc: String)(opponent: User)(questionSet: [QuestionDTO])(challengerResult: GameResultDTO?)(opponentResult: GameResultDTO?)(rejectedByOpponent: Bool)(expired: Bool) -> GameDTO {
        var date = DataFormatter.shared.dateFormatter.dateFromString(createdAtUtc)
        var selfUser: User
        var awayUser: User


        return GameDTO(id: id, challenger: challenger, opponentUser: opponent, rejectedByOpponent: rejectedByOpponent, expired: expired, questionSet: questionSet, challengerResult: challengerResult, opponentResult: opponentResult, createdAt: date)
    }

    var debugDescription: String {
        var d = "{\nGame details:\n"
        d += "ID: \(id)\n"
        d += "Created At: \(createdAt)\n"
        d += "Initiator ID: \(challenger.userId)\n"
        d += "Opponent ID: \(opponentUser.userId)\n"
        d += "Questions: "
        var i: Int = 0
        for q in questionSet {
            d += "Question \(++i): \(q)"
        }
        d += "\n}\n"
        return d
    }

    var dictionaryRepresentation: [String:AnyObject] {

        var dict: [String:AnyObject] = ["id": id,
                                        "challenger": challenger.dictionaryRepresentation,
                                        "createdAtUtc": DataFormatter.shared.dateFormatter.stringFromDate(createdAt),
                                        "opponent": opponentUser.dictionaryRepresentation,
                                        "questionSet": questionSet.map {
                                            $0.dictionaryRepresentation
                                        },
                                        "rejectedByOpponent": NSNumber(bool: rejectedByOpponent),
                                        "expired": NSNumber(bool: expired)]
        if let cRes = challengerResult {
            dict.updateValue(cRes.dictionaryRepresentation, forKey: "challengerResult")
        }
        if let oRes = opponentResult {
            dict.updateValue(oRes.dictionaryRepresentation, forKey: "opponentResult")
        }
        return dict
    }
}

func ==(lhs: GameDTO, rhs: GameDTO) -> Bool {
    return lhs.id == rhs.id &&
            lhs.challenger == rhs.challenger &&
            lhs.createdAt == rhs.createdAt &&
            lhs.opponentUser == rhs.opponentUser &&
            lhs.rejectedByOpponent == rhs.rejectedByOpponent &&
            lhs.expired == rhs.expired &&
            lhs.questionSet == rhs.questionSet;
}

