//
//  gameConfiguration.swift
//  BlackJackX
//
//  Created by Founder on 09/02/2021.
//

import Foundation

struct Game {
    static let cardSeries = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
    static let deck = Array(repeating: cardSeries, count: 4).flatMap{$0}
    static let deckDict = ["A":1,"2":2,"3":3,"4":4,"5":5,"6":6,"7":7,"8":8,"9":9,"10":10,"J":10,"Q":10,"K":10]
    static let cardCountDict = ["A":-1,"2":1,"3":1,"4":1,"5":1,"6":1,"7":0,"8":0,"9":0,"10":-1,"J":-1,"Q":-1,"K":-1]
    static let blackJackComb = [["A", "10"],["A", "J"],["A", "Q"],["A", "K"],["10", "A"],["J", "A"],["Q", "A"],["K", "A"]]
    
//    static var stillBetting = true
    static var started = false
    static var finished = false
    static var won = false
}


class Participant {
    var dealtCardsArr = [String]()
    var dealtCardsCount: (Int, Int) {
        var count = 0
        var altCount = 0
        for card in dealtCardsArr {
            count += Game.deckDict[card]!
        }
        altCount = count
        
        if (dealtCardsArr.contains("A")) && (count + 10 <= 21) {
            altCount = count + 10
        }
        return (count, altCount)
    }
    
    var bankroll: Float?
    var gameStats: localGameStatistics?
}

struct localGameStatistics {
    var parameters:[String] = ["runningCount", "trueCount", "decksLeft", "aceLeft", "aceConc", "blackJackProb"]
    var value:[Float] = [0, 0, 0, 0, 0, 0]
}
