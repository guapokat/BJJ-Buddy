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
    var selectedIndex: Int = 0
    
    //MARK: - Personal Functions
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

    }
}


//MARK: - Table
extension JournalTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as UITableViewCell
        let date = entries.reversed()[indexPath.row].date
        let time = entries.reversed()[indexPath.row].time
        
    
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = entries.reversed()[indexPath.row].date
        
        /*
         Instead of checking for date and time here...need to check for round rolled entry
         if it exists add "X rounds of X minutes"
         The subtitle field will look like:
         "X hrs - X rounds of X minutes"
         */
        if let date = date, let time = time {
            cell.detailTextLabel?.text = "X hrs - X rounds of X minutes"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Editing
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete"){
            (action, indexPath) in
         let item = self.entries[indexPath.row]
            
            //deleting
            self.context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //deleting locally
            self.entries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
