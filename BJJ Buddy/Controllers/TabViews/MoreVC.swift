//
//  MoreVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 9/12/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit
import MessageUI

class MoreVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    //MARK: - Outlets
    @IBOutlet var beltColorLabel: UILabel!
    @IBOutlet var beltColorImage: UIImageView!
    @IBOutlet var viewTitleLabel: UILabel!
    @IBOutlet var buddyIcon: UIImageView!
    
    
    //MARK: - Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var deleteString = ""
    var users: [User] = []
    var entries: [JournalEntry] = []
    let beltImages = [#imageLiteral(resourceName: "White"), #imageLiteral(resourceName: "Grey"), #imageLiteral(resourceName: "Yellow"), #imageLiteral(resourceName: "Orange"), #imageLiteral(resourceName: "Green"), #imageLiteral(resourceName: "Blue"), #imageLiteral(resourceName: "Purple"), #imageLiteral(resourceName: "Brown"), #imageLiteral(resourceName: "Black")]
    let beltNames = ["White","Grey","Yellow","Orange","Green","Blue","Purple","Brown","Black"]
    let animations = Animations()

    //MARK: - Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        BeltFunctions().changeLabelBackgroundColor(forLabel: viewTitleLabel)
        fetchData()
        //Custom data point showing user has not set belt color
        if users[0].belt >= 9 {
            beltColorLabel.isHidden = true
            beltColorImage.isHidden = true
        } else {
            beltColorLabel.text = beltNames[Int(users[0].belt)]
            beltColorImage.image = beltImages[Int(users[0].belt)]
            beltColorLabel.isHidden = false
            beltColorImage.isHidden = false
        }
        animations.moveLabelIn(forTitle: viewTitleLabel)
        animations.bringImageUp(forImage: buddyIcon)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        animations.moveLabelOut(forTitle: viewTitleLabel)
        animations.bringImageDown(forImage: buddyIcon)
    }
    
    //MARK: - Actions
    @IBAction func beltColorButton(_ sender: UIButton) {
        presentBeltPickerAlert(self)
    }
    
    @IBAction func deleteJournalEntriesButton(_ sender: UIButton) {
        presentDeleteAlert(usersOrJournals: entries, both: false)
    }
    
    @IBAction func deleteTimerStatsButton(_ sender: UIButton) {
        presentDeleteAlert(usersOrJournals: users, both: false)
    }
    
    @IBAction func deleteAllButton(_ sender: Any) {
        presentDeleteAlert(usersOrJournals: entries, both: true)
    }
    
    @IBAction func contactButton(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["vidzucreations@gmail.com"])
            mail.setSubject("BJJ Buddy - Comment")
            mail.setMessageBody("Please enter any feature requests, bugs, or comments here. I thank you for using this app and I only hope to improve it as time passes.", isHTML: true)
            //For iPads
            mail.popoverPresentationController?.sourceView = self.view
            mail.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
            mail.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            present(mail, animated: true)
        }
    }
    
    //MARK: - Custom methods
    
    //Making sure user wants to delete (similar to Github's method)
    func presentDeleteAlert(usersOrJournals: [NSObject], both: Bool) {
        let deleteAlert = UIAlertController(title: "Are you sure?", message: "Type 'Delete' to confirm.", preferredStyle: .alert)
        let config: TextField.Config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = .red
            textField.placeholder = "Delete"
            textField.left(image: #imageLiteral(resourceName: "DeleteIcon"), color: .lightGray)
            textField.leftViewPadding = 12
            textField.borderWidth = 1
            textField.cornerRadius = 8
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.isSecureTextEntry = false
            textField.returnKeyType = .done
            textField.action { textField in
                if let string = textField.text {
                    self.deleteString = string
                }
            }
        }
        deleteAlert.addOneTextField(configuration: config)
        deleteAlert.addAction(title: "OK", style: .cancel, handler: ({ action in
            if self.deleteString.lowercased() == "delete" {
                let deleteAlert = UIAlertController(title: "Delete Successful", message: "Items will be deleted", preferredStyle: .alert)
                deleteAlert.addAction(title: "OK")
                self.present(deleteAlert, animated: true, completion: nil)
                if both == true {
                    self.deleteUserStats()
                    self.deleteJournalEntries()
                } else if usersOrJournals is [JournalEntry] {
                    self.deleteJournalEntries()
                } else {
                    //delete user entries
                    self.deleteUserStats()
                }
            } else {
                let nothingDoneAlert = UIAlertController(title: "Incorrect Entry", message: "Nothing will be Deleted", preferredStyle: .alert)
                nothingDoneAlert.addAction(title: "OK")
                self.present(nothingDoneAlert, animated: true, completion: nil)
            }
        }))
        deleteAlert.show()
    }
    
    func deleteJournalEntries() {
        for item in self.entries {
            self.context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
    func deleteUserStats() {
        self.users[0].totalRounds = 0
        self.users[0].totalTimeRested = 0
        self.users[0].totalTimeRolled = 0
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func presentBeltPickerAlert(_ sendingVC: UIViewController) {
        let beltAlert = UIAlertController(title: "Pick Belt Color", message: nil, preferredStyle: .actionSheet)
        let beltChoices = ["----","White","Grey","Yellow","Orange","Green","Blue","Purple","Brown","Black"]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)
        
        beltAlert.addPickerView(values: [beltChoices], initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            beltAlert.actions[0].isEnabled = false
            if index.row == 0 {
                beltAlert.actions[0].isEnabled = false
                self.beltColorImage.isHidden = true
                self.beltColorLabel.isHidden = true
            } else {
                beltAlert.actions[0].isEnabled = true
                self.beltColorImage.image = self.beltImages[index.row - 1]
                self.beltColorLabel.text = self.beltNames[index.row - 1]
                self.beltColorImage.isHidden = false
                self.beltColorLabel.isHidden = false
                self.users[0].belt = Int16(index.row - 1)
            }
        }
        beltAlert.addAction(title: "Done", style: .default, handler: ({ action in
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            BeltFunctions().changeLabelBackgroundColor(forLabel: self.viewTitleLabel)
        }))
        //For iPads
        beltAlert.popoverPresentationController?.sourceView = self.view
        beltAlert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        beltAlert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        sendingVC.present(beltAlert, animated: true, completion: {})
    }
    
    func fetchData() {
        do {
            users = try context.fetch(User.fetchRequest())
            entries = try context.fetch(JournalEntry.fetchRequest())
            if users.isEmpty {
                let newUser = User(context: context)
                print("CREATING USER -> \(newUser)")
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                users = try context.fetch(User.fetchRequest())
            }
        } catch {
            //TODO: Error handling
            print("Couldn't fetch data")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
