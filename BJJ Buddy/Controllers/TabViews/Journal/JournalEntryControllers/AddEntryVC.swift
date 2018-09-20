//
//  AddEntryVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 8/22/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class AddEntryVC: UIViewController, UITextViewDelegate {
    
    //MARK: - Variables
    let defaultText = "Enter notes from today's training. Include things like positions and techniques drilled. Each week come back and review what you need to work on and what you have mastered! Remember Jiu Jitsu is a journey. A black belt is just a white belt who never quit! Oss!"
    var trainingTimeAmount: Int?
    var rollingTimeAmount: Int?
    var numberOfRounds: Int?
    
    //MARK: - Outlets
    @IBOutlet weak var entryField: UITextView!
    @IBOutlet weak var trainingUISwitch: UISwitch!
    @IBOutlet weak var trainingMinutesLabel: UILabel!
    @IBOutlet weak var rollingMinutesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var viewTitleLabel: UILabel!
    
    //MARK: - Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        Animations().moveLabelIn(forTitle: viewTitleLabel)
        Animations().bringFieldIn(forView: entryField)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        entryField.delegate = self
        entryField.textColor = UIColor.lightGray
        
        trainingMinutesLabel.isHidden = true
        rollingMinutesLabel.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Animations().moveLabelOut(forTitle: viewTitleLabel)
    }
    
    //MARK: - Text View
    
        //sets text color to black on edit and empties field
    func textViewDidBeginEditing(_ textView: UITextView) {
        entryField.textColor = #colorLiteral(red: 0.1607843137, green: 0.1607843137, blue: 0.1647058824, alpha: 1)
        entryField.text = nil
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if entryField.text.isEmpty {
            entryField.text = defaultText
            entryField.textColor = UIColor.lightGray
        }
    }
    
        //dismissing on touch anywhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Actions
    
    @IBAction func AddPressed(_ sender: UIButton) {
        guard let entryText = entryField?.text else { return }
        
        //if empty alert
        if entryText.isEmpty || entryField?.text == defaultText {
            let alert = UIAlertController(title: "Please type something", message: "Your entry was left blank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
            self.present(alert, animated: true, completion: nil)
        } else {
            
            guard let entryText = entryField?.text else {
                return
            }
            
            //Date formatting
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/YY"
            let currentDate = formatter.string(from: date)
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            let currentTime = timeFormatter.string(from: date)
            
            //Make entry item
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newEntry = JournalEntry(context: context)
            newEntry.entry = entryText
            newEntry.date = currentDate
            newEntry.time = currentTime
            
            if let trainTime = trainingTimeAmount {
                newEntry.trainingTime = Int16(trainTime)
            }

            if let rollTime = rollingTimeAmount {
                newEntry.rollingTime = Int16(rollTime)
            }
            
            if let numOfRounds = numberOfRounds {
                newEntry.numberOfRounds = Int16(numOfRounds)
            }
            
            //Save
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            dismiss(animated: true, completion: nil)
        }
    }
    
        //Time Switches
    
    //Training/Class
    @IBAction func trainingTimeToggled(_ sender: UISwitch) {
        if sender.isOn {
            presentMinutePickeralert(self)
        } else {
            trainingMinutesLabel.isHidden = true
            trainingTimeAmount = nil
        }
    }
    
    //Rolling/Sparring
    @IBAction func rollingTimeToggled(_ sender: UISwitch) {
        if sender.isOn {
            presentRollingPickerAlertFirst(self)
        } else {
            rollingMinutesLabel.isHidden = true
            rollingTimeAmount = nil
        }
    }
    
    
    @IBAction func CancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - CUSTOM FUNCTIONS
    func presentMinutePickeralert(_ sendingVC: UIViewController) {
        let alert = UIAlertController(title: "Add Time", message: "How many minutes was training/class?", preferredStyle: .actionSheet)
        let minuteChoices = Array(15...180).map{ CGFloat($0) }
        let pickerViewValues: [[String]] = [minuteChoices.map{ Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: minuteChoices.index(of: 60) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.trainingTimeAmount = Int(minuteChoices[index.row])
            self.trainingMinutesLabel.text = "\(self.trainingTimeAmount!) Minutes"
            self.trainingMinutesLabel.isHidden = false
        }
        
        alert.addAction(title: "Done", style: .default)

        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        sendingVC.present(alert, animated: true, completion: {
            if self.trainingMinutesLabel.isHidden {
                self.trainingTimeAmount = 60
                self.trainingMinutesLabel.text = "\(self.trainingTimeAmount!) Minutes"
                self.trainingMinutesLabel.isHidden = false
            }
        })
    }
    
    func presentRollingPickerAlertFirst(_ sendingVC: UIViewController) {
        
        let roundAlert = UIAlertController(title: "Add Rounds", message: "How many rounds did you roll/spar for?", preferredStyle: .actionSheet)
        let roundChoices = Array(1...10).map{ CGFloat($0) }
        let roundPickerViewValues: [[String]] = [roundChoices.map{ Int($0).description }]
        let roundPickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: roundChoices.index(of: 5) ?? 0)
        
        roundAlert.addPickerView(values: roundPickerViewValues, initialSelection: roundPickerViewSelectedValue) { vc, picker, index, values in
            self.numberOfRounds = Int(roundChoices[index.row])
        }

        roundAlert.addAction(title: "Done", style: .default, handler: { action in
            if self.numberOfRounds == nil {
                self.numberOfRounds = 5
            }
            self.presentRollingPickerAlertSecond(self)
        })
        roundAlert.popoverPresentationController?.sourceView = self.view
        roundAlert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        roundAlert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        sendingVC.present(roundAlert, animated: true, completion: {})
    }
    
    func presentRollingPickerAlertSecond(_ sendingVC: UIViewController) {
        let alert = UIAlertController(title: "Add Time", message: "How many minutes per round?", preferredStyle: .actionSheet)
        let minuteChoices = Array(1...9).map{ CGFloat($0) }
        let pickerViewValues: [[String]] = [minuteChoices.map{ Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: minuteChoices.index(of: 5) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.rollingTimeAmount = Int(minuteChoices[index.row])
        }
        
        alert.addAction(title: "Done", style: .default, handler:  { action in
            if self.rollingTimeAmount == nil {
                self.rollingTimeAmount = 5
            }
            self.updateRollingLabel(numberOfRounds: self.numberOfRounds!, timePerRound: self.rollingTimeAmount!)
        })
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        sendingVC.present(alert, animated: true, completion: {})
    }
    
    func updateRollingLabel(numberOfRounds: Int, timePerRound: Int) {
        self.rollingMinutesLabel.text = "\(numberOfRounds) Round(s) of \(timePerRound) Min(s)"
        self.rollingMinutesLabel.isHidden = false
    }
}
