//
//  ViewController.swift
//  BlackJackX
//
//  Created by Founder on 08/02/2021.
//

import UIKit
import RealmSwift

class InitialViewController: UIViewController {
    
    // MARK: - Variables
    var decks: Int?
    var bankroll: Int?
    
    @IBOutlet weak var decksLabel: UILabel!
    @IBOutlet weak var decksSlider: UISlider!
    @IBOutlet weak var bankrollLabel: UILabel!
    @IBOutlet weak var bankrollSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSliderConfiguration()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func defaultSliderConfiguration() {
        decksSlider.maximumValue = 6
        decksSlider.minimumValue = 0
        decksSlider.value = (decksSlider.maximumValue/2)
        decks = Int(decksSlider.value)
        
        bankrollSlider.maximumValue = 1000
        bankrollSlider.minimumValue = 30
        bankrollSlider.value = (bankrollSlider.maximumValue/2)
        bankroll = Int(bankrollSlider.value)
    }
    
    // MARK: - Sliders Function
    @IBAction func decksSliderChanged(_ sender: UISlider) {
        decks = Int(sender.value)
        decksLabel.text = "\(decks!)"
    }
    
    @IBAction func bankrollSliderChanged(_ sender: UISlider) {
        bankroll = Int(sender.value)
        bankrollLabel.text = "£ \(bankroll!)"
    }
    
    // MARK: - Prepare & Perform Segue
    @IBAction func playButtonPressed(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "play" {
            let destinationVC = segue.destination as! GameViewController
            destinationVC.decksNumber = decks
            destinationVC.startingBankroll = Float(bankroll!)
        } else if segue.identifier == "stats" {
            
        }
    }


}

