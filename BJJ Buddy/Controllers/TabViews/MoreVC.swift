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
    var users: [User] = []
    let beltImages = [#imageLiteral(resourceName: "White"), #imageLiteral(resourceName: "Grey"), #imageLiteral(resourceName: "Yellow"), #imageLiteral(resourceName: "Orange"), #imageLiteral(resourceName: "Green"), #imageLiteral(resourceName: "Blue"), #imageLiteral(resourceName: "Purple"), #imageLiteral(resourceName: "Brown"), #imageLiteral(resourceName: "Black")]
    let beltNames = ["White","Grey","Yellow","Orange","Green","Blue","Purple","Brown","Black"]

    //MARK: - LIFECYCLE FUNCTIONS
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        if users.isEmpty {
            beltColorLabel.isHidden = true
            beltColorImage.isHidden = true
        } else if users[0].belt > 6 {
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
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    @IBAction func deleteJournalEntriesButton(_ sender: UIButton) {
    }
    
    @IBAction func deleteTimerStatsButton(_ sender: UIButton) {
    }
    
    @IBAction func deleteAllButton(_ sender: Any) {
    }
    
    //MARK: - CUSTOM FUNCTIONS
    func fetchData() {
        do {
            users = try context.fetch(User.fetchRequest())
        } catch {
            //TODO: - Error handling
            print("Couldn't fetch data")
        }
    }
    
    func presentBeltPickerAlert(_ sendingVC: UIViewController) {
        let beltAlert = UIAlertController(style: .actionSheet, title: "Pick Belt Color", message: nil)
        let beltChoices = [
            "White \(#imageLiteral(resourceName: "White"))", "Grey \(#imageLiteral(resourceName: "Grey"))", "Yellow \(#imageLiteral(resourceName: "Yellow"))", "Orange \(#imageLiteral(resourceName: "Orange"))", "Green \(#imageLiteral(resourceName: "Green"))", "Blue \(#imageLiteral(resourceName: "Blue"))", "Purple \(#imageLiteral(resourceName: "Purple"))", "Brown \(#imageLiteral(resourceName: "Brown"))", "Black \(#imageLiteral(resourceName: "Black"))",
        ]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)
        
        beltAlert.addPickerView(values: [beltChoices], initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.beltColorImage.image = self.beltImages[index.row]
            self.beltColorImage.isHidden = false
            self.beltColorLabel.text = self.beltNames[index.row]
            self.users[0].belt = Int16(index.row)
        }
        
        beltAlert.addAction(title: "Done", style: .default)
        sendingVC.present(beltAlert, animated: true, completion: {
            if self.beltColorImage.isHidden {
                //defaulting to white if picker view errors out
                self.beltColorImage.image = self.beltImages[0]
                self.beltColorImage.isHidden = false
                self.beltColorLabel.text = self.beltNames[0]
                self.beltColorLabel.isHidden = false
            }
        })
        
    }
}
