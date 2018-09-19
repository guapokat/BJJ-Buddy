//
//  beltFunctions.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 9/18/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class BeltFunctions {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var users: [User] = []
    var color = Colors()
    
    func changeLabelBackgroundColor(forLabel: UILabel) {
        fetchData()
        if users.isEmpty {
            forLabel.shadowColor = nil
        } else {
            //forLabel.shadowOpacity = 0.2
            switch users[0].belt {
            case 0:
                forLabel.shadowColor = color.whiteBelt
            case 1:
                forLabel.shadowColor = color.greyBelt
            case 2:
                forLabel.shadowColor = color.yellowBelt
            case 3:
                forLabel.shadowColor = color.orangeBelt
            case 4:
                forLabel.shadowColor = color.greenBelt
            case 5:
                forLabel.shadowColor = color.blueBelt
            case 6:
                forLabel.shadowColor = color.purpleBelt
            case 7:
                forLabel.shadowColor = color.brownBelt
            case 8:
                forLabel.shadowColor = color.blackBelt
            default:
                forLabel.shadowColor = nil
            }
        }
    }
    
    func fetchData() {
        do {
            users = try context.fetch(User.fetchRequest())
            if users.isEmpty {
                return
            }
        } catch {
            //TODO: error handling
            print("Couldn't fetch data")
        }
    }
}
