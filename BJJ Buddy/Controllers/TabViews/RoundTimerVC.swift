//
//  RoundTimerVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 9/6/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class RoundTimerVC: UIViewController,UITextFieldDelegate {
    
    //MARK: - OUTLETS
    @IBOutlet var startButton: UIButton!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var numberOfRounds: UITextField!
    @IBOutlet var roundLength: [UITextField]!
    @IBOutlet var restInterval: [UITextField]!
    
    var rounds = 0
    var length = 0
    var rest = 0
    
    //MARK: - VARIABLES
    let limitLength = 2
    

    //MARK: - LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        assignDelegates()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toTimer") {
            
            convertFields()
            
            if let nextVC = segue.destination as? TimerVC {
                nextVC.numberOfRounds = rounds
                nextVC.roundLength = length
                nextVC.restInterval = rest
            }
            
            clearText()
        }
    }
    
    
    //MARK: - ACTIONS
    @IBAction func startPressed(_ sender: UIButton) {
        checkFields()
    }
    @IBAction func clearPressed(_ sender: UIButton) {
        clearText()
    }
    
    //MARK: CUSTOM METHODS
    func convertFields() {
        print("** CONVERTING FIELDS **")
        var tempRoundLength = 0 //seconds
        var tempRestLength = 0 //seconds
        
        if let value = Int(numberOfRounds.text!) {
            rounds = value
        }
        
        if rounds == 0 {
            rounds = 1
        }
        
        print("CONVERTFIELD Rounds -> \(rounds)")
        
        if let roundLengthMinute = Int(roundLength[0].text!) {
            tempRoundLength += roundLengthMinute * 60 //in seconds
        }
        if let roundLengthSeconds = Int(roundLength[1].text!) {
            tempRoundLength += roundLengthSeconds
        }
        print("CONVERTFIELD Round Length -> \(tempRoundLength)")
        length = tempRoundLength
        
        if let restLengthMinute = Int(restInterval[0].text!) {
            tempRestLength += restLengthMinute * 60 //in seconds
        }
        if let restLengthSeconds = Int(restInterval[1].text!) {
            tempRestLength += restLengthSeconds
        }
        print("CONVERTFIELD Rest Length -> \(tempRestLength)")
        rest = tempRestLength
    }
    
    func checkFields() {
        if roundLength[0].text == "" && roundLength[1].text == "" {
            alert(forCondition: 2)
        } else if restInterval[0].text == "" && restInterval[1].text == "" && numberOfRounds.text == ""{
            alert(forCondition: 4)
        } else if restInterval[0].text == "" && restInterval[1].text == "" {
            alert(forCondition: 3)
        } else if numberOfRounds.text == "" {
            alert(forCondition: 1)
        } else {
            performSegue(withIdentifier: "toTimer", sender: self)
        }
    }
    
    func alert(forCondition: Int) {
        let title1 = "Defaulting to 1 round"
        let title2 = "Round Length"
        let title3 = "Rest?"
        
        if forCondition == 1 {
            let alert = UIAlertController(title: title1, message: "Continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.performSegue(withIdentifier: "toTimer", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        } else if forCondition == 2 {
            let alert = UIAlertController(title: title2, message: "Please enter a round length", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        } else if forCondition == 3 {
            let alert = UIAlertController(title: title3, message: "Do you want a rest between rounds?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { action in }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                self.performSegue(withIdentifier: "toTimer", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        } else if forCondition == 4 {
            let alert = UIAlertController(title: title3, message: "Do you want a rest between rounds? Also rounds will default to 1.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { action in }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                self.performSegue(withIdentifier: "toTimer", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func assignDelegates() {
        numberOfRounds.delegate = self
        for field in roundLength {
            field.delegate = self
        }
        for field in restInterval {
            field.delegate = self
        }
    }
    
    func clearText() {
        numberOfRounds.text = ""
        for field in roundLength {
            field.text = ""
        }
        for field in restInterval {
            field.text = ""
        }
        rounds = 0
        length = 0
        rest = 0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= limitLength
    }
    
}

