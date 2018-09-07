//
//  timerVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 9/6/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class TimerVC: UIViewController {
    
    //MARK: - VARIABLES
    var timer = Timer()
    var isTimerRunning = false
    var resume = false
    //from segue
    var numberOfRounds = 0
    var roundLength = 0
    var restInterval = 0
    var currentRoundLength = 0
    
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
        
        print("\nNumberOfRounds -> \(numberOfRounds)")
        print("roundLength -> \(roundLength)")
        print("restInterval -> \(restInterval)")
        
        initialDisplay()
        stopButton.isEnabled = false
        
    }
    
    //MARK: - CUSTON METHODS
    func runTimer() {
        //TODO: Sounds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerVC.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    @objc func updateTimer() {
        if currentRoundLength < 1 {
            timer.invalidate()
            //TODO: END ROUND
            
            startButton.setTitle("Start", for: .normal)
        } else {
            currentRoundLength -= 1
            updateDisplay(withTime: currentRoundLength)
        }
    }
    
    func initialDisplay() {
        let minutes = configureMinutes(withTime: roundLength)
        let seconds = configureSeconds(withTime: roundLength)
        
        if minutes == 0 {
            minutesField.text! = "00"
        } else {
            minutesField.text! = String(minutes)
        }
        
        if seconds == 0 {
            secondsField.text! = "00"
        } else {
            secondsField.text! = String(seconds)
        }
        
        currentRoundLength = roundLength
    }
    
    func updateDisplay(withTime: Int) {
        let minutes = configureMinutes(withTime: withTime)
        minutesField.text! = String(format: "%02i", minutes)
        //minutesField.text! = "\(configureMinutes(withTime: withTime))"
        let seconds = configureSeconds(withTime: withTime)
        secondsField.text! = String(format: "%02i", seconds)
        //secondsField.text! = "\(configureSeconds(withTime: withTime))"
    }
    
    func configureMinutes(withTime: Int) -> Int {
        return withTime / 60
    }
    
    func configureSeconds(withTime: Int) -> Int {
        return withTime % 60
    }
    
    //MARK: - ACTIONS
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        if isTimerRunning == false {
            runTimer()
            self.startButton.setTitle("Pause", for: .normal)
            self.stopButton.isEnabled = true
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
