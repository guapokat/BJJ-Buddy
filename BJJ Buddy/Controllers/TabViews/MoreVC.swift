//
//  MoreVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 9/12/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class MoreVC: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet var beltColorLabel: UILabel!
    @IBOutlet var beltColorImage: UIImageView!
    
    //MARK: - VARIABLES
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var deleteString = ""
    var users: [User] = []
    var entries: [JournalEntry] = []
    let beltImages = [#imageLiteral(resourceName: "White"), #imageLiteral(resourceName: "Grey"), #imageLiteral(resourceName: "Yellow"), #imageLiteral(resourceName: "Orange"), #imageLiteral(resourceName: "Green"), #imageLiteral(resourceName: "Blue"), #imageLiteral(resourceName: "Purple"), #imageLiteral(resourceName: "Brown"), #imageLiteral(resourceName: "Black")]
    let beltNames = ["White","Grey","Yellow","Orange","Green","Blue","Purple","Brown","Black"]

    //MARK: - LIFECYCLE FUNCTIONS
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        if users[0].belt >= 9 {
            beltColorLabel.isHidden = true
            beltColorImage.isHidden = true
        } else {
            beltColorLabel.text = beltNames[Int(users[0].belt)]
            beltColorImage.image = beltImages[Int(users[0].belt)]
            beltColorLabel.isHidden = false
            beltColorImage.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - ACTIONS
    @IBAction func beltColorButton(_ sender: UIButton) {
        presentBeltPickerAlert(self)
    }
    
    @IBAction func deleteJournalEntriesButton(_ sender: UIButton) {
        presentDeleteAlert(usersOrJournals: entries)
    }
    
    @IBAction func deleteTimerStatsButton(_ sender: UIButton) {
        presentDeleteAlert(usersOrJournals: users)
    }
    
    @IBAction func deleteAllButton(_ sender: Any) {
        presentDeleteAlert(usersOrJournals: entries)
        presentDeleteAlert(usersOrJournals: users)
    }
    
    //MARK: - CUSTOM FUNCTIONS
    
    func presentDeleteAlert(usersOrJournals: [NSObject]) {
        let deleteAlert = UIAlertController(style: .alert, title: "Are you sure?", message: "Type 'Delete' to delete all journal entries.")
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
                if usersOrJournals is [JournalEntry] {
                    //delete journal entries
                    for item in self.entries {
                        self.context.delete(item)
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    }
                } else {
                    //delete user entries
                    self.users[0].totalRounds = 0
                    self.users[0].totalTimeRested = 0
                    self.users[0].totalTimeRolled = 0
                }
            } else {
                print("Nothing Done") //TODO: - handle this case
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }))
        deleteAlert.show()
    }
    
    func presentBeltPickerAlert(_ sendingVC: UIViewController) {
        let beltAlert = UIAlertController(style: .actionSheet, title: "Pick Belt Color", message: nil)
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
        }))
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
            //TODO: - Error handling
            print("Couldn't fetch data")
        }
    }

}
