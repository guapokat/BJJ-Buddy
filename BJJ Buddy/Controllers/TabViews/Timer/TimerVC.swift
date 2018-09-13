//
//  timerVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 9/6/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit
import SwiftySound

class TimerVC: UIViewController {
    
    //MARK: - VARIABLES
    
    //from segue
    var numberOfRounds = 0
    var prepTime = 0
    var roundLength = 0
    var restInterval = 0
    //local use
    var timer = Timer()
    var isTimerRunning = false
    var resume = false
    var prepRound = false
    var restRound = false
    var regularRound = false
    var currentRoundTime = 0
    var roundsCompleted = 0
    var totalTimeRolled = 0
    var totalTimeRested = 0
    var tempCounter = 0
    
    //MARK: - OUTLETS
    @IBOutlet var roundLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var minutesField: UITextField!
    @IBOutlet var secondsField: UITextField!
    @IBOutlet var stopButton: UIButton!
    
    //allowing anything but upside down
    @objc func canRotate() -> Void {}

    //MARK: - LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        if prepTime == 0 {
            roundLabel.text = "Round 1"
            prepRound = false
            regularRound = true
            currentRoundTime = roundLength
            updateDisplay(withTime: currentRoundTime)
        } else {
            roundLabel.text = "Get Ready"
            prepRound = true
            regularRound = false
            currentRoundTime = prepTime
            updateDisplay(withTime: prepTime)
        }
    }
    
    //MARK: - CUSTON METHODS
    
    @objc func updateTimer() {
        
        if prepRound {
            roundLabel.text = "Get Ready"
        }
        
        //10 second warning
        if regularRound && currentRoundTime == 11 {
            Sound.stopAll()
            Sound.play(file: "warning", fileExtension: "mp3", numberOfLoops: 2)
        }
        
        //if current round ended
        if currentRoundTime < 1 {
            stopTimer()
            
            //If prep round ended
            if prepRound {
                setUpRegularRound()
            }
                
            //if a regular round ended
            else if regularRound {
                roundsCompleted += 1
                //If done
                if roundsCompleted == numberOfRounds {
                    roundLabel.text = "END"
                    endSession()
                }
                //If rest exists
                else if restInterval > 0 {
                    setUpRestRound()
                }
                //If rest does not exist
                else if restInterval == 0 {
                   setUpRegularRound()
                } else {
                    roundLabel.text = "END"
                    endSession()
                }
            }
                
            //If a rest round ended
            else if restRound {
                setUpRegularRound()
            }
        }

        //Running the current round
        else {
            currentRoundTime -= 1
            if currentRoundTime == 0 && regularRound {
                Sound.stopAll()
                Sound.play(file: "roundStart.mp3")
            }
            if restRound {
                totalTimeRested += 1
                tempCounter += 1
            }
            if regularRound {
                totalTimeRolled += 1
                tempCounter += 1
            }
            updateDisplay(withTime: currentRoundTime)
        }
    }
    
    func runTimer() {
        isTimerRunning = true
        if regularRound {
            Sound.stopAll()
            Sound.play(file: "roundStart.mp3")
        }
        startButton.setTitle("Pause", for: .normal)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerVC.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func setUpRestRound() {
        tempCounter = 0
        print("\ntempCounter -> \(tempCounter)")
        roundLabel.text = "REST"
        restRound = true
        prepRound = false
        regularRound = false
        updateDisplay(withTime: restInterval)
        currentRoundTime = restInterval
        runTimer()
    }
    
    func setUpRegularRound() {
        tempCounter = 0
        print("\ntempCounter -> \(tempCounter)")
        roundLabel.text = "Round \(roundsCompleted + 1)"
        restRound = false
        prepRound = false
        regularRound = true
        updateDisplay(withTime: roundLength)
        currentRoundTime = roundLength
        runTimer()
    }
    
    func updateDisplay(withTime: Int) {
        let minutes = configureMinutes(withTime: withTime)
        minutesField.text! = String(format: "%02i", minutes)
        let seconds = configureSeconds(withTime: withTime)
        secondsField.text! = String(format: "%02i", seconds)
    }
    
    func configureMinutes(withTime: Int) -> Int {
        return withTime / 60
    }
    
    func configureSeconds(withTime: Int) -> Int {
        return withTime % 60
    }
    
    func stopTimer() {
        timer.invalidate()
        isTimerRunning = false
        self.startButton.setTitle("Start", for: .normal)
    }
    
    func resetRound() {
        if restRound {
            print("totalRounds \(roundsCompleted)")
            print("totalTimeRested \(totalTimeRested) - tempCounter \(tempCounter)")
            totalTimeRested -= tempCounter
            print("\t=\(totalTimeRested)")
            currentRoundTime = restInterval
            tempCounter = 0
        } else if regularRound {
            print("totalRounds \(roundsCompleted)")
            print("totalTimeRolled \(totalTimeRolled) - tempCounter \(tempCounter)")
            totalTimeRolled -= tempCounter
            print("\t=\(totalTimeRolled)")
            if roundLabel.text == "END" {
                roundsCompleted -= 1
                roundLabel.text = "Round \(roundsCompleted + 1)"
            }
            currentRoundTime = roundLength
            tempCounter = 0
        }
        if startButton.title(for: .normal) == "Pause" {
            startButton.setTitle("Start", for: .normal)
        }
        if startButton.isEnabled == false {
            startButton.isEnabled = true
        }
        
        updateDisplay(withTime: currentRoundTime)
    }
    
    func resetCompletley() {
        roundsCompleted = 0
        totalTimeRested = 0
        totalTimeRolled = 0
        tempCounter = 0
        currentRoundTime = roundLength
        updateDisplay(withTime: roundLength)
        roundLabel.text = "Round 1"
        if startButton.title(for: .normal) == "Pause" {
            startButton.setTitle("Start", for: .normal)
        }
        if startButton.isEnabled == false {
            startButton.isEnabled = true
        }
    }
    
    func endSession() {
        roundLabel.text = "END"
        startButton.isEnabled = false
        presentSaveOption()
    }
    
    func presentSaveOption() {
        let saveAlert = UIAlertController(title: "Exit", message: "Save to stats before exiting?", preferredStyle: .actionSheet)
        let saveButton = UIAlertAction(title: "Yes", style: .default, handler: { action in
            print("Save pressed")
            self.saveToUser()
        })
        let declineButton = UIAlertAction(title: "No", style: .destructive, handler: { action in
            self.dismiss(animated: true, completion: nil)
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in })
        saveAlert.addAction(saveButton)
        saveAlert.addAction(declineButton)
        saveAlert.addAction(cancelButton)
        
        present(saveAlert, animated: true, completion: nil)
    }
    
    func saveToUser() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var users: [User]
        
        do {
            let myGroup = DispatchGroup()
            users = try context.fetch(User.fetchRequest())
            if users.isEmpty {
                myGroup.enter()
                let newUser = User(context: context)
                newUser.totalRounds = 0
                newUser.totalTimeRested = 0
                newUser.totalTimeRolled = 0
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                print("user saved")
                users = try context.fetch(User.fetchRequest())
                myGroup.leave()
            }
            myGroup.notify(queue: DispatchQueue.main) {
                let user = users[0] //ERROR HERE
                user.totalRounds += Int64(self.roundsCompleted)
                user.totalTimeRolled += Int64(self.totalTimeRolled)
                user.totalTimeRested += Int64(self.totalTimeRested)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.dismiss(animated: true, completion: nil)
            }
        } catch {
            print("Couldn't fetch user")
        }
    }
    //MARK: - ACTIONS
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        if isTimerRunning == false {
            runTimer()
        } else {
            stopTimer()
        }
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        stopTimer()
        presentSaveOption()
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        stopTimer()
        let alert = UIAlertController(title: "Reset", message: nil, preferredStyle: .actionSheet)
        let roundButton = UIAlertAction(title: "Reset Current Round", style: .default, handler: { action in
            self.resetRound()
        })
        let sessionButton = UIAlertAction(title: "Reset Session", style: .destructive, handler: { action in
            self.resetCompletley()
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("Cancel button chose")
        })
        alert.addAction(roundButton)
        alert.addAction(sessionButton)
        alert.addAction(cancelButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        stopTimer()
        dismiss(animated: true, completion: nil)
    }
}
