//
//  GameViewController.swift
//  BlackJackX
//
//  Created by Founder on 08/02/2021.
//

import Foundation
import UIKit
import RealmSwift

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    var decksNumber: Int?
    var startingBankroll: Float?
    
    var player = Participant()
    var dealer = Participant()
    var gameDecks = [String]()
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var dealerCountLabel: UILabel!
    @IBOutlet weak var dealerCardsLabel: UILabel!
    @IBOutlet weak var playerCardsLabel: UILabel!
    @IBOutlet weak var playerCountLabel: UILabel!
    @IBOutlet weak var splitButton: UIButton!
    @IBOutlet weak var hitButton: UIButton!
    @IBOutlet weak var standButton: UIButton!
    @IBOutlet weak var doubleButton: UIButton!
    @IBOutlet var funcButton: [UIButton]!
    @IBOutlet var betButton: [UIButton]!
    @IBOutlet weak var bankrollLabel: UILabel!
    @IBOutlet weak var localGameStatsTable: UITableView!
    @IBOutlet weak var overallStatsButton: UIButton!
    
    var bet: Float = 0
    var bankrollCount: Float = 0
    var gameFinishedCardCounter: Int = 0
    var localGameStatsDict: Dictionary<String, Float> = [:]
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        createDecks()
        initialGameSettings()
        gameStatsDictInit()
        
        player.bankroll = startingBankroll!
        bankrollLabel.text = "£\(player.bankroll!)"
        
        localGameStatsTable.delegate = self
        localGameStatsTable.dataSource = self
        localGameStatsTable.rowHeight = 30
    }
    
    func createDecks() {
        for _ in 1...decksNumber! {
            gameDecks.append(contentsOf: Game.deck)
        }
    }
    
    func initialGameSettings() {
        player = Participant()
        dealer = Participant()
        dealerCountLabel.text = "Dealer Count"
        playerCountLabel.text = "Plyaer Count"
        dealerCardsLabel.text = "Dealer Cards"
        playerCardsLabel.text = "Player Cards"
        
        Game.started = false
        Game.finished = false
        Game.won = false
        updateButtonView()
        
        nextButton.isEnabled = false
        show(betButton)
        betButton.forEach({$0.backgroundColor = UIColor.systemTeal})
        
        player.gameStats = localGameStatistics()
    }
    
    // MARK: - Next
    @IBAction func nextButtonPressed(_ sender: Any) {
        initialGameSettings()
        player.bankroll = bankrollCount
    }
    
    // MARK: - Split
    @IBAction func splitButtonPressed(_ sender: UIButton) {
        
    }
    
    // MARK: - Hit
    @IBAction func hitButtonPressed(_ sender: UIButton) {
        playerHit()
        reloadGameView()
    }
    
    func deal(_ participant: Participant) {
        let card = gameDecks[Int.random(in: 0...gameDecks.count)]
        let index = gameDecks.firstIndex(of: card)
        gameDecks.remove(at: index!)
        participant.dealtCardsArr.append(card)
    }
    
    func playerHit() {
        if !Game.started {
            deal(player)
            deal(dealer)
            deal(player)
        } else {
            if player.dealtCardsCount.1 < 21 {
                deal(player)
            }
        }
        Game.started = true
        if player.dealtCardsCount.1 >= 21 {
            dealerHit()
        }
    }
    
    // MARK: - Stand
    @IBAction func standButtonPressed(_ sender: UIButton) {
        dealerHit()
        reloadGameView()
    }
    
    func dealerHit() {
        while dealer.dealtCardsCount.1 < 17 {
            deal(dealer)
        }
        Game.finished = true
    }
    
    // MARK: - Double
    @IBAction func doubleButtonPressed(_ sender: UIButton) {
        bet = bet * 2
        hitButtonPressed(sender)
        dealerHit()
        reloadGameView()
    }
    
    // MARK: - Bet
    @IBAction func betButtonPressed(_ sender: UIButton) {
        betButton.forEach({$0.backgroundColor = UIColor.systemTeal})
        sender.backgroundColor = UIColor.green
        bet = Float(sender.tag * 5)
        hitButton.isHidden = false
    }
    
    // MARK: - Local Stats Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let statsKey = ["runningCount", "trueCount"]
        let floatedValue = [localGameStatsDict[statsKey[0]], localGameStatsDict[statsKey[1]]]
        var statsValue:[String] = []
        for value in floatedValue {
            if value == floor(value!) {
                statsValue.append(String(Int(value!)))
            } else {
                statsValue.append(String(format: "%.2f", value!))
            }
        }
        cell.textLabel?.text = "\(statsKey[indexPath.row]): " + statsValue[indexPath.row]
        return cell
    }
    
    // MARK: - All Statistics Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "statsTable" {
            let destinationVC = segue.destination as! StatisticsTableViewController
            destinationVC.localStatistics = localGameStatsDict
        }
    }
    
    // MARK: - Game View Reload
    func reloadGameView() {
        let (dealerCount, playerCount) = updateCount()
        dealerCountLabel.text = dealerCount
        playerCountLabel.text = playerCount
        
        dealerCardsLabel.text = dealer.dealtCardsArr.joined(separator: ",")
        playerCardsLabel.text = player.dealtCardsArr.joined(separator: ",")
        
        if Game.finished {
            updateBankroll()
            bankrollLabel.text = "£\(player.bankroll!)"
        }
        
        updateButtonView()
        updatePlayerStatistics()
    }
    
    // MARK: - Update Count
    func updateCount() -> (String, String) {
        let (dealerCount, dealerAltCount) = dealer.dealtCardsCount
        let (playerCount, playerAltCount) = player.dealtCardsCount
        var playerDisplay = "\(playerAltCount)"
        var dealerDisplay = "\(dealerAltCount)"
        
        if (playerCount != playerAltCount) {
            playerDisplay = "\(playerCount)/\(playerAltCount)"
        }
        
        if (playerCount == playerAltCount) || (playerAltCount == 21) || Game.finished {
            playerDisplay = "\(playerAltCount)"
        }
        
        if (dealerCount <= 21) && (dealerAltCount <= 21) && (dealerCount != dealerAltCount) && (dealerAltCount < 17) {
            dealerDisplay = "\(dealerCount)/\(dealerAltCount)"
        }
        
        if (dealerAltCount > 17) && (dealerAltCount <= 21) {
            dealerDisplay = "\(dealerAltCount)"
        }
        
        return (dealerDisplay, playerDisplay)
    }
    
    // MARK: - Update Bankroll
    func updateBankroll() {
        let (_, dealerAltCount) = dealer.dealtCardsCount
        let (_, playerAltCount) = player.dealtCardsCount
        let playerBlackJack = Game.blackJackComb.contains(player.dealtCardsArr)
        let dealerBlackJack = Game.blackJackComb.contains(dealer.dealtCardsArr)
        
        var multiplier:Float = 0
        
        if (playerBlackJack && !dealerBlackJack) {
            multiplier = 1.5
            Game.won = true
        }
        
        if ((playerAltCount > dealerAltCount) || (dealerAltCount > 21)) && (playerAltCount <= 21) && !playerBlackJack {
            multiplier = 1
            Game.won = true
        }
        
        if (playerBlackJack && dealerBlackJack) || (playerAltCount == dealerAltCount) {
            multiplier = 0
        }
        
        if (!playerBlackJack && dealerBlackJack) || (playerAltCount > 21) || ((playerAltCount < dealerAltCount) && dealerAltCount <= 21) {
            multiplier = -1
        }
        
        player.bankroll! += multiplier * bet
        bankrollCount = player.bankroll!
    }
    
    // MARK: - Update Button View
    func updateButtonView() {
        switch (Game.started, Game.finished) {
        case (false, _):
            hide(funcButton)
        case (true, false):
            hide(betButton)
            show(funcButton)
        default:
            hide(funcButton)
            nextButton.isEnabled = true
        }
    }
    
    func hide(_ buttonArray: [UIButton]) {
        for button in buttonArray {
            button.isHidden = true
        }
    }
    
    func show(_ buttonArray: [UIButton]) {
        
        for button in buttonArray {
            button.isHidden = false
        }
        
        switch player.dealtCardsArr.count {
        case 2:
            if player.dealtCardsArr[0] != player.dealtCardsArr[1] {
                splitButton.isHidden = true
            }
        default:
            splitButton.isHidden = true
            doubleButton.isHidden = true
        }
    }
    
    // MARK: - Update Player Local Statistics
    
    func updatePlayerStatistics() {
        updateLocalStatistics()
        updatePublicStatistics()
//        runningCountLabel.text = String(format: "%.2f", player.gameStats!.trueCount)
    }
    
    func gameStatsDictInit() {
        let playerStats = player.gameStats
        for i in 0...(playerStats!.parameters.count - 1) {
            let key = playerStats!.parameters[i]
            localGameStatsDict[key] = playerStats!.value[i]
        }
        print(localGameStatsDict)
    }
    
    func updateLocalStatistics() {
        let cardsPerGame = player.dealtCardsArr + dealer.dealtCardsArr
        
        // Running Count
        var runningCountPerHit:Int = 0
        for card in cardsPerGame {
            runningCountPerHit += Game.cardCountDict[card]!
            localGameStatsDict["runningCount"] = Float(gameFinishedCardCounter + runningCountPerHit)
        }
        
        if Game.finished {
            gameFinishedCardCounter = Int(localGameStatsDict["runningCount"]!)
        }
        
        // Decks Left
        let cardLeft = gameDecks.count
        localGameStatsDict["decksLeft"] = Float(cardLeft)/52
        
        // True Count
        localGameStatsDict["trueCount"] = localGameStatsDict["runningCount"]!/localGameStatsDict["decksLeft"]!
        
        // Ace Count
        let aceLeftPerGame:Int = specificCount(Card: "A")
        localGameStatsDict["aceLeft"] = Float(aceLeftPerGame)
        
        // Ace Concentration
        localGameStatsDict["aceConc"] = (Float(aceLeftPerGame)/(Float(gameDecks.count)/52))/400
        
        // BlackJack Probability
        let highCardsLeft = specificCount(Card: "10", "J", "Q", "K")
        localGameStatsDict["blackJackProb"] = !Game.started ? Float((highCardsLeft/cardLeft)*(aceLeftPerGame/(cardLeft-1))) : 0
        
        self.localGameStatsTable.reloadData()
    }
    
    // MARK: - Update Player Overall Statistics
    var realm = try! Realm()
    var publicGameStats: Results<PublicGameStatsParameter>?
    
    func updatePublicStatistics() {
        let gamePlayed = PublicGameStatsParameter()
        let gameWon = PublicGameStatsParameter()
        let winRate = PublicGameStatsParameter()
        publicGameStats = realm.objects(PublicGameStatsParameter.self)
        
        if publicGameStats!.count == 0 {
            save(publicStats: gamePlayed)
            save(publicStats: gameWon)
            save(publicStats: winRate)
        }
        
        if Game.finished {
            let playerBlackJack = Game.blackJackComb.contains(player.dealtCardsArr)
            
            try! realm.write {
                if Game.won {
                    publicGameStats![1].count += 1
                }
                if playerBlackJack {
                    publicGameStats![3].count += 1
                }
                publicGameStats![0].count += 1
                publicGameStats![2].count = Float(publicGameStats![1].count/publicGameStats![0].count)
            }
        }
        
    }
    
    func save(publicStats: PublicGameStatsParameter) {
        do {
            try realm.write {
                realm.add(publicStats)
            }
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func specificCount(Card: String...) -> Int {
        var specificCount = 0
        for card in gameDecks {
            for targetCard in Card {
                if card == targetCard {
                    specificCount += 1
                }
            }
        }
        return specificCount
    }
    
    
}
