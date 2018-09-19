//
//  RoundTimerVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 9/6/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class RoundTimerVC: UIViewController, UITextFieldDelegate {
    
    //MARK: - OUTLETS
    @IBOutlet var startButton: UIButton!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var numberOfRounds: UITextField!
    @IBOutlet var prepTime: [UITextField]!
    @IBOutlet var roundLength: [UITextField]!
    @IBOutlet var restInterval: [UITextField]!
    @IBOutlet var viewTitleLabel: UILabel!
    @IBOutlet var buddyIcon: UIImageView!
    
    var rounds = 0
    var prep = 0
    var length = 0
    var rest = 0
    let animations = Animations()
    
    //MARK: - VARIABLES
    let limitLength = 2 //character limit
    
    //MARK: - LIFECYCLE METHODS
    override func viewWillAppear(_ animated: Bool) {
        BeltFunctions().changeLabelBackgroundColor(forLabel: viewTitleLabel)
        animations.moveLabelIn(forTitle: viewTitleLabel)
        animations.bringImageUp(forImage: buddyIcon)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignDelegates()
        
        //Dismiss keyboard on touch
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        animations.moveLabelOut(forTitle: viewTitleLabel)
        animations.bringImageDown(forImage: buddyIcon)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toTimer") {
            
            convertFields()
            
            if let nextVC = segue.destination as? TimerVC {
                nextVC.numberOfRounds = rounds
                nextVC.prepTime = prep
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
    
    //Converting to useful types
    func convertFields() {
        var tempPrepLength = 0
        var tempRoundLength = 0 //seconds
        var tempRestLength = 0 //seconds
        
        //Number of Rounds --------------------------------------
        if let value = Int(numberOfRounds.text!) {
            rounds = value
        }
        
        if rounds == 0 {
            rounds = 1
        }
        //-------------------------------------------------------
        
        //Prep Time ---------------------------------------------
        if let prepTimeMinute = Int(prepTime[0].text!) {
            tempPrepLength += convertMinute(forTime: prepTimeMinute)
        }
        
        if let prepTimeSeconds = Int(prepTime[1].text!) {
            tempPrepLength += prepTimeSeconds
        }
        
        prep = tempPrepLength
        
        //-------------------------------------------------------

        //Round Time ---------------------------------------------
        if let roundLengthMinute = Int(roundLength[0].text!) {
            tempRoundLength += convertMinute(forTime: roundLengthMinute)
        }
        
        if let roundLengthSeconds = Int(roundLength[1].text!) {
            tempRoundLength += roundLengthSeconds
        }
        
        length = tempRoundLength
        
        //-------------------------------------------------------
        
        //Rest Time ---------------------------------------------
        if let restLengthMinute = Int(restInterval[0].text!) {
            tempRestLength += convertMinute(forTime: restLengthMinute)
        }
        
        if let restLengthSeconds = Int(restInterval[1].text!) {
            tempRestLength += restLengthSeconds
        }
        
        rest = tempRestLength
        //-------------------------------------------------------
    }
    
    func convertMinute(forTime: Int) -> Int {
        var seconds = 0
        seconds += forTime * 60 //minutes to seconds
        return seconds
    }
    
    //Assuring fields are filled properly
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
            //converts values on segue call
            performSegue(withIdentifier: "toTimer", sender: self)
        }
    }
    
    //Alert helper
    func alert(forCondition: Int) {
        let title1 = "Defaulting to 1 round"
        let title2 = "Round Interval"
        let title3 = "Rest Interval"
        
        if forCondition == 1 || forCondition == 4{
            let alert = UIAlertController(title: title1, message: "Continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in }))
            alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: {
                action in
                self.performSegue(withIdentifier: "toTimer", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        } else if forCondition == 2 {
            let alert = UIAlertController(title: title2, message: "Please enter a round length", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        } else if forCondition == 3 {
            let alert = UIAlertController(title: title3, message: "Rest between rounds?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No (continue)", style: .cancel, handler: { action in
                self.performSegue(withIdentifier: "toTimer", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Yes (Go Back)", style: .default, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func assignDelegates() {
        numberOfRounds.delegate = self
        for field in prepTime {
            field.delegate = self
        }
        for field in roundLength {
            field.delegate = self
        }
        for field in restInterval {
            field.delegate = self
        }
    }
    
    //Resets labels and local variables
    func clearText() {
        numberOfRounds.text = ""
        for field in prepTime {
            field.text = ""
        }
        for field in roundLength {
            field.text = ""
        }
        for field in restInterval {
            field.text = ""
        }
        rounds = 0
        prep = 0
        length = 0
        rest = 0
    }
    
    //Limiting uitextfields to 2 characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= limitLength
    }
    
    //if user types nothing or something above 60
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let value = textField.text {
            var intText = Int(value)
            if let checkValue = intText {
                if checkValue >= 60 {
                    intText = 59
                }
            }
            guard let g2g = intText else { return }
            setText(forField: textField, withText: String(g2g))
        } else {
            return
        }
    }
    
    //Textfield display
    func setText(forField: UITextField, withText: String) {
        guard let intText = Int(withText) else { return }
        forField.text = String(format: "%02i", intText)
    }
    
}

