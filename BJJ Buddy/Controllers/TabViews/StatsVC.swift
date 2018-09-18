//
//  StatsVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 9/11/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class StatsVC: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet var totalTrainingTimeLabel: UILabel!
    @IBOutlet var totalRollingTimeLabel: UILabel!
    @IBOutlet var totalRestTimeLabel: UILabel!
    @IBOutlet var totalRoundsRolledLabel: UILabel!
    @IBOutlet var totalJournalEntriesLabel: UILabel!
    @IBOutlet var averageWordsPerEntryLabel: UILabel!
    
    //MARK: - VARIABLES
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var users: [User] = []
    var entries: [JournalEntry] = []
    
    var totalTrainingTime = 0
    var totalRollingTime = 0
    var totalRestTime = 0
    var totalRoundsRolled = 0
    var totalJournalEntries = 0
    var averageWordsPerEntry = 0

    //MARK: - LIFECYCLE FUNCTIONS
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        let emptyCheck = checkIfEmpty()
        switch emptyCheck {
        case 0:
            updateDisplay()
        case 1:
            configureUserEntityStats()
            updateDisplay()
        case 2:
            configureJournalEntryStats()
            
            updateDisplay()
        default:
            configureJournalEntryStats()
            configureUserEntityStats()
            updateDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reset()
    }
    
    //MARK: - CUSTOM FUNCTIONS
    func reset() {
        totalTrainingTime = 0
        totalRollingTime = 0
        totalRestTime = 0
        totalRoundsRolled = 0
        totalJournalEntries = 0
        averageWordsPerEntry = 0
    }
    func checkIfEmpty() -> Int {
        if users.isEmpty && entries.isEmpty {
            return 0 //no user & no entries
        } else if entries.isEmpty && !users.isEmpty {
            return 1 //no entries but has user
        } else if !entries.isEmpty && users.isEmpty {
            return 2 //entries with no user
        } else {
            return 3 //both present
        }
    }
    
    func fetchData() {
        do {
            entries = try context.fetch(JournalEntry.fetchRequest())
            users = try context.fetch(User.fetchRequest())
        } catch {
            //TODO: - Error handling
            print("Couldn't fetch data")
        }
    }
    
    func configureJournalEntryStats() {
        for entry in entries {
            //Minutes into 60
            totalTrainingTime += Int(entry.trainingTime * 60)
            //Seconds
            totalRollingTime += Int(entry.numberOfRounds) * Int(entry.rollingTime * 60)
            totalRoundsRolled += Int(entry.numberOfRounds)
        }
        //Journal Entry count & Average words
        totalJournalEntries = entries.count
        let numberOfWords = countWords()
        let averageWordCount = numberOfWords / totalJournalEntries
        averageWordsPerEntry = averageWordCount
    }
    
    func configureUserEntityStats() {
        totalTrainingTime += Int(users[0].totalClassTime)
        totalRollingTime += Int(users[0].totalTimeRolled)
        totalRestTime += Int(users[0].totalTimeRested)
        totalRoundsRolled += Int(users[0].totalRounds)
    }
    
    func updateDisplay() {
        if totalTrainingTime != 0 {
            totalTrainingTimeLabel.text = makeTimeString(forTime: totalTrainingTime)
        } else {
            totalTrainingTimeLabel.text = "N/A"
        }
        if totalRollingTime != 0 {
            totalRollingTimeLabel.text = makeTimeString(forTime: totalRollingTime)
        } else {
            totalRollingTimeLabel.text = "N/A"
        }
        if totalRestTime != 0 {
            totalRestTimeLabel.text = makeTimeString(forTime: totalRestTime)
        } else {
            totalRestTimeLabel.text = "N/A"
        }
        if totalRoundsRolled != 0 {
            totalRoundsRolledLabel.text = "\(totalRoundsRolled)"
        } else {
            totalRoundsRolledLabel.text = "N/A"
        }
        if totalJournalEntries != 0 {
            totalJournalEntriesLabel.text = "\(totalJournalEntries)"
        } else {
            totalJournalEntriesLabel.text = "N/A"
        }
        if averageWordsPerEntry != 0 {
            averageWordsPerEntryLabel.text = "\(averageWordsPerEntry)"
        } else {
            averageWordsPerEntryLabel.text = "N/A"
        }
    }
    
    func makeTimeString(forTime: Int) -> String {
        var timeString = ""
        var hours = 0
        var minutes = 0
        var seconds = 0
        
        hours = forTime / 3600
        minutes = (forTime % 3600) / 60
        seconds = (forTime % 3600) % 60

        if hours == 0 && minutes == 0 && seconds != 00 {
            timeString = "\(seconds)(s)"
            return timeString
        } else if hours == 0 && minutes != 0 && seconds == 00 {
            timeString = "\(minutes)(m)"
            return timeString
        } else if hours != 0 && minutes == 0 && seconds == 00 {
            timeString = "\(hours)(h)"
            return timeString
        } else if hours != 0 && minutes != 0 && seconds == 00 {
            timeString = "\(hours)(h) - \(minutes)(m)"
            return timeString
        } else if hours != 0 && minutes != 0 && seconds != 00 {
            timeString = "\(hours)(h) - \(minutes)(m) - \(seconds)(s)"
            return timeString
        } else if hours == 0 && minutes != 0 && seconds != 00 {
            timeString = "\(minutes)(m) - \(seconds)(s)"
            return timeString
        } else {
            timeString = "\(hours)(h) - \(seconds)(s)"
            return timeString
        }
    }
    
    func countWords() -> Int  {
        var wordCount = 0
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        for entry in entries {
            let components = entry.entry?.components(separatedBy: chararacterSet)
            let words = components?.filter { !$0.isEmpty }
            wordCount += (words?.count)!
        }
        return wordCount
    }
    
    //MARK: - ACTIONS
    @IBAction func facebookButton(_ sender: UIButton) {
        // Screenshot:
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let items = [img]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
}
