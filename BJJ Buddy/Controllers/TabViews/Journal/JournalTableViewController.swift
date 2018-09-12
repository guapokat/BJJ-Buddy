//
//  JournalTableViewController.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 8/22/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class JournalTableViewController: UITableViewController {
    
    //MARK: - Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entries: [JournalEntry] = []
    var selectedIndex: Int!
    
    //MARK: - CUSTOM FUNCTIONS
    func fetchData() {
        do {
            //Gathering from core data
            entries = try context.fetch(JournalEntry.fetchRequest())
            //updating table
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            //TODO: * ERROR HANDLING *
            print("Couldn't fetch data")
        }
    }

    //MARK: - Lifecycle Functions
    
    //Making sure table is updated before it is presentedd
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            let updateVC = segue.destination as! EditEntryVC
            updateVC.entry = entries.reversed()[selectedIndex!]
        }
    }
}

//MARK: - Table
extension JournalTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as UITableViewCell
        let date = entries.reversed()[indexPath.row].date
        let entry = entries.reversed()[indexPath.row].entry
        let trainingTime = entries.reversed()[indexPath.row].trainingTime
        let timePerRound = entries.reversed()[indexPath.row].rollingTime
        let rounds = entries.reversed()[indexPath.row].numberOfRounds

        cell.textLabel?.numberOfLines = 0
        
        if let date = date, let entry = entry {
            let entryBrief =  entry.prefix(99)
            let titleString = date + "\t" + entryBrief + "..."
            cell.textLabel?.text = titleString
            
            if trainingTime != 0 && timePerRound == 0 {
                cell.detailTextLabel?.text = "Training: \(trainingTime) Minutes"
            } else if trainingTime == 0 && timePerRound != 0 {
                cell.detailTextLabel?.text = "Rolled: \(rounds) round(s) of \(timePerRound) min(s)"
            } else if trainingTime != 0 && timePerRound != 0 {
                cell.detailTextLabel?.text = "Training: \(trainingTime) Minutes | Rolled: \(rounds) round(s) of \(timePerRound) min(s)"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Editing (allowing delete)
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete"){
            (action, indexPath) in
            let item = self.entries.reversed()[indexPath.row]
            //deleting
            self.context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //deleting locally
            self.entries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            self.fetchData()
        }
        
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //for segue
        selectedIndex = indexPath.row
        
        //no highlight
        tableView.deselectRow(at: indexPath, animated: true)
        
        //perform segue
        performSegue(withIdentifier: "toEdit", sender: self)
    }
}
