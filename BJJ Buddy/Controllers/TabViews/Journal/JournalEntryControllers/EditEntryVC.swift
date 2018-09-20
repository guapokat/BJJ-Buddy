//
//  EditEntryVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 8/22/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class EditEntryVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet var entryView: UITextView!
    @IBOutlet var trainingTimeLabel: UILabel!
    @IBOutlet var rollingTimeLabel: UILabel!
    @IBOutlet var trainingTimeSwitch: UISwitch!
    @IBOutlet var rollingTimeSwitch: UISwitch!
    @IBOutlet var viewTitleLabel: UILabel!
    
    
    //MARK: - Variables
    var entry: JournalEntry!
    var trainingTime: Int?
    var rollingTime: Int?
    var numberOfRounds: Int?
    
    //MARK: - LifeCycle Methods
    override func viewWillAppear(_ animated: Bool) {
        Animations().moveLabelIn(forTitle: viewTitleLabel)
        Animations().bringFieldIn(forView: entryView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trainingTimeLabel.isHidden = true
        rollingTimeLabel.isHidden = true
        trainingTimeSwitch.isOn = false
        rollingTimeSwitch.isOn = false
        
        configureEntryData(entry: entry)
        configureTimeLabels(entry: entry)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Animations().moveLabelOut(forTitle: viewTitleLabel)
    }
    
    //dismissing on touch anywhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Custom Methods
    func configureEntryData(entry: JournalEntry) {
        if let entryText = entry.entry {
            entryView.text = entryText
        } else {
            entryView.text = "Nothing to update"
        }
    }
    
    func configureTimeLabels(entry: JournalEntry) {
        //Setting up labels at bottom of view
        if entry.trainingTime != 0 {
            trainingTimeLabel.text = "\(entry.trainingTime) Minutes"
            trainingTimeLabel.isHidden = false
            trainingTimeSwitch.isOn = true
        }
        if entry.rollingTime != 0 {
            rollingTimeLabel.text = "\(entry.numberOfRounds) Round(s) of \(entry.rollingTime) Min(s)"
            rollingTimeLabel.isHidden = false
            rollingTimeSwitch.isOn = true
        }
    }
    
    //Minute picker
    func presentMinutePickeralert(_ sendingVC: UIViewController) {
        let alert = UIAlertController(title: "Add Time", message: "How many minutes was training/class?", preferredStyle: .actionSheet)
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
            //if picker is sending nil (user didn't wait for picker to settle)
            if self.trainingTimeLabel.isHidden {
                self.trainingTime = 60
                self.trainingTimeLabel.text = "\(self.trainingTime!) Minutes"
                self.trainingTimeLabel.isHidden = false
            }
        })
    }
    
    //Round picker
    func presentRollingPickerAlertFirst(_ sendingVC: UIViewController) {
        let alert = UIAlertController(title: "Add Rounds", message: "How many rounds did you roll/spar for?", preferredStyle: .actionSheet)
        let roundChoices = Array(1...10).map{ CGFloat($0) }
        let pickerViewValues: [[String]] = [roundChoices.map{ Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: roundChoices.index(of: 5) ?? 0)
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.numberOfRounds = Int(roundChoices[index.row])
        }
        alert.addAction(title: "Done", style: .default, handler: { action in
            //if picker is sending nil (user didn't wait for picker to settle)
            if self.numberOfRounds == nil {
                self.numberOfRounds = 5
            }
            //Presenting minutes per round picker
            self.presentRollingPickerAlertSecond(self)
        })
        sendingVC.present(alert, animated: true, completion: nil)
    }
    
    //Minutes per round
    func presentRollingPickerAlertSecond(_ sendingVC: UIViewController) {
        let alert = UIAlertController(title: "Add Time", message: "How many minutes per round?", preferredStyle: .actionSheet)
        let minuteChoices = Array(1...9).map{ CGFloat($0) }
        let pickerViewValues: [[String]] = [minuteChoices.map{ Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: minuteChoices.index(of: 5) ?? 0)
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.rollingTime = Int(minuteChoices[index.row])
        }
        alert.addAction(title: "Done", style: .default, handler:  { action in
            //if picker is sending nil (user didn't wait for picker to settle)
            if self.rollingTime == nil {
                self.rollingTime = 5
            }
            self.updateRollingLabel(numberOfRounds: self.numberOfRounds!, timePerRound: self.rollingTime!)
        })
        sendingVC.present(alert, animated: true, completion: nil)
    }

    //Updating The rolling label only
    func updateRollingLabel(numberOfRounds: Int, timePerRound: Int) {
        self.rollingTimeLabel.text = "\(numberOfRounds) Round(s) of \(timePerRound) Min(s)"
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
            trainingTime = nil
        }
    }
    
    @IBAction func rollingTimeToggled(_ sender: UISwitch) {
        if sender.isOn {
            presentRollingPickerAlertFirst(self)
        } else {
            rollingTimeLabel.isHidden = true
            rollingTime = nil
        }
    }

    @IBAction func updatePressed(_ sender: UIButton) {
        //making sure there is text
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
            //SAVE
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            dismiss(animated: true, completion: nil)
        }
    }
}
