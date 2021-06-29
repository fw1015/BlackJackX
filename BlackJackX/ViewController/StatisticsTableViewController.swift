//
//  StatisticsTableViewController.swift
//  BlackJackX
//
//  Created by Founder on 08/02/2021.
//

import UIKit
import RealmSwift

class StatisticsTableViewController: UITableViewController {

    var realm = try! Realm()
    var publicGameStats: Results<PublicGameStatsParameter>?
    var localStatistics:Dictionary<String,Float> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStatistics()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let globalStatsKey = ["Game Played", "Game Won", "Win Rate"]
        var globalStatsValue:[Float] = []
        for i in 0...2 {
            let realmStatsValue = publicGameStats?[i].count
            globalStatsValue.append(realmStatsValue!)
        }
        
        let localStatsKey = ["runningCount", "trueCount", "decksLeft", "aceLeft", "aceConc"]
        var localStatsValue:[Float] = []
        for i in 0...4 {
            localStatsValue.append(localStatistics[localStatsKey[i]]!)
        }
        
        let statsKey = globalStatsKey + localStatsKey
        let floatedValue = globalStatsValue + localStatsValue
        var statsValue:[String] = []
        for value in floatedValue {
            if value == floor(value) {
                statsValue.append(String(Int(value)))
            } else {
                statsValue.append(String(format: "%.2f", value))
            }
        }
        
        cell.textLabel?.text = "\(statsKey[indexPath.row]): " + statsValue[indexPath.row]
        return cell
    }
    
    func loadStatistics() {
        publicGameStats = realm.objects(PublicGameStatsParameter.self)
        tableView.reloadData()
    }

}
