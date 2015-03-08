//
//  GameDTO.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 6/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import Argo
import Runes

struct GameDTO: JSONDecodable, DebugPrintable, Equatable, DictionaryRepresentation  {
        let id: Int
        let challenger: User
        let opponentUser: User
        let rejectedByOpponent: Bool
        let expired: Bool
        let questionSet: [QuestionDTO]
        let challengerResult: GameResultDTO?
        let opponentResult: GameResultDTO?
        let selfUser: User
        let awayUser: User
        var createdAt: NSDate!
    
        static func decode(j: JSONValue) -> GameDTO? {
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
    
    static func create(id: Int)(challenger: User)(createdAtUtc: String)(opponent: User)(questionSet: [QuestionDTO])(challengerResult: GameResultDTO?)(opponentResult: GameResultDTO?)(rejectedByOpponent: Bool)(expired: Bool) -> GameDTO {
        var date = DataFormatter.shared.dateFormatter.dateFromString(createdAtUtc)
        var selfUser:User
        var awayUser:User
        
        var selfIsCreator = challenger.userId == NetworkClient.sharedClient.user.userId
        
        return GameDTO(id: id, challenger: challenger,  opponentUser: opponent, rejectedByOpponent: rejectedByOpponent, expired: expired, questionSet: questionSet, challengerResult: challengerResult, opponentResult: opponentResult, selfUser: selfIsCreator ? challenger : opponent, awayUser:  selfIsCreator ? opponent : challenger, createdAt: date)
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
    
    var dictionaryRepresentation: [String: AnyObject]{
        
//        let questionSetDictionary = questionSet.map {
//            $0.dictionary
//        }
        
        return ["id" : id,
        "challenger": challenger.dictionaryRepresentation,
        "createdAtUtc": DataFormatter.shared.dateFormatter.stringFromDate(createdAt),
        "opponent": opponentUser.dictionaryRepresentation,
        "questionSet": [] //
        ]
    }
}

func ==(lhs: GameDTO, rhs: GameDTO) -> Bool{
    return lhs.id == rhs.id &&
        lhs.challenger == rhs.challenger &&
        lhs.createdAt == rhs.createdAt &&
        lhs.opponentUser == rhs.opponentUser &&
        lhs.rejectedByOpponent == rhs.rejectedByOpponent &&
        lhs.expired == rhs.expired &&
        lhs.questionSet == rhs.questionSet;
}

