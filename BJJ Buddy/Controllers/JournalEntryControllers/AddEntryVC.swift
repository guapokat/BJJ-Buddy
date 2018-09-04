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
    
    //MARK: - Outlets
    @IBOutlet weak var entryField: UITextView!
    @IBOutlet weak var trainingUISwitch: UISwitch!
    @IBOutlet weak var trainingMinutesLabel: UILabel!
    @IBOutlet weak var rollingMinutesLabel: UILabel!
    
    
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        entryField.delegate = self
        entryField.textColor = UIColor.lightGray
        
        trainingMinutesLabel.isHidden = true
        rollingMinutesLabel.isHidden = true
    }
    
    //MARK: - Text View
    
        //sets text color to black on edit and empties field
    func textViewDidBeginEditing(_ textView: UITextView) {
        if entryField.textColor == UIColor.lightGray {
            entryField.text = nil
            entryField.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if entryField.text.isEmpty {
            entryField.text = defaultText
            entryField.textColor = UIColor.lightGray
        }
    }
    
    
    
        //dismissing on return button
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
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
            presentRollingPickerAlert(self)
        } else {
            rollingMinutesLabel.isHidden = true
            rollingTimeAmount = nil
        }
    }
    
    
    @IBAction func CancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Personal Functions
    func presentMinutePickeralert(_ sendingVC: UIViewController) {
        
        let alert = UIAlertController(style: .actionSheet, title: "Add Time", message: "How many minutes was training/class?")//, tintColor: <#T##UIColor?#>)
        let minuteChoices = Array(15...180).map{ CGFloat($0) }
        let pickerViewValues: [[String]] = [minuteChoices.map{ Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: minuteChoices.index(of: 60) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.trainingTimeAmount = Int(minuteChoices[index.row])
            self.trainingMinutesLabel.text = "\(self.trainingTimeAmount!) Minutes"
            self.trainingMinutesLabel.isHidden = false
        }
        
        
        alert.addAction(title: "Done", style: .cancel)
        sendingVC.present(alert, animated: true, completion: {
            if self.trainingMinutesLabel.isHidden {
                self.trainingTimeAmount = 60
                self.trainingMinutesLabel.text = "\(self.trainingTimeAmount!) Minutes"
                self.trainingMinutesLabel.isHidden = false
            }
        })
        
    }
    
    func presentRollingPickerAlert(_ sendingVC: UIViewController) {
        
        let alert = UIAlertController(style: .actionSheet, title: "Add Time", message: "How many minutes did you roll or spar for?")//, tintColor: <#T##UIColor?#>)
        let minuteChoices = Array(15...180).map{ CGFloat($0) }
        let pickerViewValues: [[String]] = [minuteChoices.map{ Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: minuteChoices.index(of: 60) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.rollingTimeAmount = Int(minuteChoices[index.row])
            self.rollingMinutesLabel.text = "\(self.rollingTimeAmount!) Minutes"
            self.rollingMinutesLabel.isHidden = false
        }

        alert.addAction(title: "Done", style: .cancel)
        sendingVC.present(alert, animated: true, completion: {
            if self.rollingMinutesLabel.isHidden {
                self.rollingTimeAmount = 60
                self.rollingMinutesLabel.text = "\(self.rollingTimeAmount!) Minutes"
                self.rollingMinutesLabel.isHidden = false
            }
        })
        
    }
    
}
