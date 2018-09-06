//
//  RoundTimerVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 9/6/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class RoundTimerVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var startButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - ACTIONS
    @IBAction func startPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toTimer", sender: self)
    }
    @IBAction func stopPressed(_ sender: UIButton) {
        
    }
}
