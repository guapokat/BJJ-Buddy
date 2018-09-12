//
//  EditEntryVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 8/22/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class EditEntryVC: UIViewController {

    //MARK: - OUTLETS
    @IBOutlet var entryView: UITextView!
    @IBOutlet var trainingTimeLabel: UILabel!
    @IBOutlet var rollingTimeLabel: UILabel!
    @IBOutlet var trainingTimeSwitch: UISwitch!
    @IBOutlet var rollingTimeSwitch: UISwitch!
    
    
    //MARK: - Variables
    var entry: JournalEntry!
    var trainingTime: Int?
    var rollingTime: Int?
    var numberOfRounds: Int?
    
    //MARK: - System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trainingTimeLabel.isHidden = true
        rollingTimeLabel.isHidden = true
        trainingTimeSwitch.isOn = false
        rollingTimeSwitch.isOn = false
        
        configureEntryData(entry: entry)
        configureTimeLabels(entry: entry)
        
    }
    
    //dismissing on touch anywhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Personal Functions
    func configureEntryData(entry: JournalEntry) {
        if let entryText = entry.entry {
            entryView.text = entryText
        } else {
            entryView.text = "Nothing to update"
        }
    }
    
    func configureTimeLabels(entry: JournalEntry) {
        
        if entry.trainingTime != 0 {
            trainingTimeLabel.text = "\(entry.trainingTime) Minutes"
            trainingTimeLabel.isHidden = false
            trainingTimeSwitch.isOn = true
        }
        if entry.rollingTime != 0 {
            rollingTimeLabel.text = "\(entry.numberOfRounds) Rounds of \(entry.rollingTime) Minutes"
            rollingTimeLabel.isHidden = false
            rollingTimeSwitch.isOn = true
        }
    }
    
    func presentMinutePickeralert(_ sendingVC: UIViewController) {
        let alert = UIAlertController(style: .actionSheet, title: "Add Time", message: "How many minutes was training/class?")
        let minuteChoices = Array(15...180).map{ CGFloat($0) }
        let pickerViewValues: [[String]] = [minuteChoices.map{ Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: minuteChoices.index(of: 60) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.trainingTime = Int(minuteChoices[index.row])
            self.trainingTimeLabel.text = "\(self.trainingTime!) Minutes"
            self.trainingTimeLabel.isHidden = false
        }
        
        alert.addAction(title: "Done", style: .cancel)
        sendingVC.present(alert, animated: true, completion: {
            if self.trainingTimeLabel.isHidden {
                self.trainingTime = 60
                self.trainingTimeLabel.text = "\(self.trainingTime!) Minutes"
                self.trainingTimeLabel.isHidden = false
            }
        })
    }
    
    func presentRollingPickerAlertFirst(_ sendingVC: UIViewController) {
        
        let alert = UIAlertController(style: .actionSheet, title: "Add Rounds", message: "How many rounds did you roll/spar for?")
        let roundChoices = Array(1...10).map{ CGFloat($0) }
        let pickerViewValues: [[String]] = [roundChoices.map{ Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: roundChoices.index(of: 5) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.numberOfRounds = Int(roundChoices[index.row])
        }
        
        alert.addAction(title: "Done", style: .default, handler: { action in
            if self.numberOfRounds == nil {
                self.numberOfRounds = 5
            }
            self.presentRollingPickerAlertSecond(self)
        })
        sendingVC.present(alert, animated: true, completion: {})

    }
    
    func presentRollingPickerAlertSecond(_ sendingVC: UIViewController) {
        let alert = UIAlertController(style: .actionSheet, title: "Add Time", message: "How many minutes per round?")
        let minuteChoices = Array(1...9).map{ CGFloat($0) }
        let pickerViewValues: [[String]] = [minuteChoices.map{ Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: minuteChoices.index(of: 5) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.rollingTime = Int(minuteChoices[index.row])
        }
        
        alert.addAction(title: "Done", style: .default, handler:  { action in
            if self.rollingTime == nil {
                self.rollingTime = 5
            }
            self.updateRollingLabel(numberOfRounds: self.numberOfRounds!, timePerRound: self.rollingTime!)
            
        })
        sendingVC.present(alert, animated: true, completion: {})
    }

    func updateRollingLabel(numberOfRounds: Int, timePerRound: Int) {
        self.rollingTimeLabel.text = "\(numberOfRounds) Rounds of \(timePerRound) Minutes"
        self.rollingTimeLabel.isHidden = false
    }
    
    //MARK: - ACTIONS

    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func trainingTimeToggled(_ sender: UISwitch) {
        if sender.isOn {
            presentMinutePickeralert(self)
        } else {
            trainingTimeLabel.isHidden = true
            trainingTime = 0
        }
    }
    
    @IBAction func rollingTimeToggled(_ sender: UISwitch) {
        if sender.isOn {
            presentRollingPickerAlertFirst(self)
        } else {
            rollingTimeLabel.isHidden = true
            rollingTime = 0
        }
    }

    @IBAction func updatePressed(_ sender: UIButton) {
        guard let newEntry = entryView?.text else { return }
        
        //if empty alert
        if newEntry.isEmpty || entryView?.text == " " || entryView?.text == "\n" {
            let alert = UIAlertController(title: "Please type something", message: "Your entry was left blank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
            self.present(alert, animated: true, completion: nil)
        } else {
            guard let entryText = entryView?.text else { return }
            entry.entry = entryText
            if let trainTime = trainingTime {
                entry.trainingTime = Int16(trainTime)
            }
            if let rollTime = rollingTime {
                entry.rollingTime = Int16(rollTime)
            }
            if let rounds = numberOfRounds {
                entry.numberOfRounds = Int16(rounds)
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            dismiss(animated: true, completion: nil)
        }
    }
}
