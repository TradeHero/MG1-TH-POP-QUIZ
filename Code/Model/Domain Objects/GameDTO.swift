//
//  GameDTO.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 6/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import Argo
import Runes

/*
{
    "id": 106,
    "createdByUserId": 543276,
    "createdAtUtc": "2014-11-11T03:22:07",
    "opponentUserId": 589267,
    "questionSet": [ ],
    "rejectedByOpponent": false,
    "expired": false
}*/

struct GameDTO: JSONDecodable, DebugPrintable, Equatable {
        let id: Int
        let createdByUserId: Int
        let createdAtUtcStr: String
        let opponentUserId: Int
        let rejectedByOpponent: Bool
        let expired: Bool
        
        var createdAt: NSDate!
        
        static func decode(j: JSONValue) -> GameDTO? {
            return self.create
            <^> j <| "id"
            <*> j <| "createdByUserId"
            <*> j <| "createdAtUtc"
            <*> j <| "opponentUserId"
            <*> j <| "rejectedByOpponent"
            <*> j <| "expired"
        }
        
        static func create(id: Int)(createdByUserId: Int)(createdAtUtc: String)(opponentUserId: Int)(rejectedByOpponent: Bool)(expired: Bool) -> GameDTO {
                var date = DataFormatter.shared.dateFormatter.dateFromString(createdAtUtc)
                return GameDTO(id: id, createdByUserId: createdByUserId, createdAtUtcStr: createdAtUtc, opponentUserId: opponentUserId, rejectedByOpponent: rejectedByOpponent, expired: expired, createdAt: date)
        }

         var debugDescription: String {
                var d = "{\nGame details:\n"
                d += "ID: \(id)\n"
                d += "Created At: \(createdAt)\n"
                d += "Initiator ID: \(createdByUserId)\n"
                d += "Opponent ID: \(opponentUserId)\n"
                d += "Questions: "
                var i: Int = 0
//                if let qs = questionSet {
//            for q in qs {
//                    d += "Question \(++i): \(q)"
//            }
//                }
                d += "\n}\n"
                return d
        }
}

func ==(lhs: GameDTO, rhs: GameDTO) -> Bool{
    return lhs.id == rhs.id &&
    lhs.createdByUserId == rhs.createdByUserId &&
    lhs.createdAtUtcStr == rhs.createdAtUtcStr &&
    lhs.opponentUserId == rhs.opponentUserId &&
    lhs.rejectedByOpponent == rhs.rejectedByOpponent &&
    lhs.expired == rhs.expired;
}

