//
//  InterfaceController.swift
//  hrtwiliocallwatch Extension
//
//  Created by Elizabeth Siegle on 1/2/17.
//  Copyright © 2017 Elizabeth Siegle. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit
import WatchConnectivity
import UIKit

class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, WCSessionDelegate, WKExtensionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    @IBOutlet private weak var label: WKInterfaceLabel!
    @IBOutlet var heart: WKInterfaceLabel!
    @IBOutlet private weak var startStopButton : WKInterfaceButton!
    var maxArr : Double!
    var minArr : Double!
    var arrHr = [Double]()
    
    let healthStore = HKHealthStore()
    
    //State of the app - is the workout activated
    var workoutActive = false
    
    var hrVal : Double = 0
    // define the activity type and location
    var workoutSesh : HKWorkoutSession?
    var wcSesh : WCSession!
    let hrUnit = HKUnit(from: "count/min")
    var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    var currQuery : HKQuery?
    var isMoving:Bool = false
    //    override init() {
    //
    //    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            label.setText("!available😤")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            displayNotAllowed()
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
            if success == false {
                self.displayNotAllowed()
                return
            }
        }
        if(WCSession.isSupported()) {
            wcSesh = WCSession.default()
            wcSesh.delegate = self
            wcSesh.activate()
        }
        self.maxArr = 0
        self.minArr = 0
    }
    
    func displayNotAllowed() {
        label.setText("!allowed😤")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            workoutDidStart(date)
        case .ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)🤔")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        NSLog("Workout error🎉")
    }
    
    
    func workoutDidStart(_ date : Date) {
        guard let query = createHeartRateStreamingQuery(date) else {
            label.setText("!start😱")
            return
        }
        healthStore.execute(query)
        self.isMoving = true
    }
    
    func workoutDidEnd(_ date : Date) {
        //if createHeartRateStreamingQuery(date) != nil {
        if let query = createHeartRateStreamingQuery(date) {
            //healthStore.stop(self.currQuery!)
            healthStore.stop(query)
            label.setText("---")
            workoutSesh = nil
            self.isMoving = false
        }
        else {
            label.setText("can't stop😏")
        }
    }
    
    // MARK: - Actions
    @IBAction func startBtnTapped() {
        if (self.isMoving) {
            //finish the current workout
            self.isMoving = false
            self.startStopButton.setTitle("Start💅🏽")
            if let workout = self.workoutSesh {
                healthStore.end(workout)
            }
            let heartRateArr = ["heartRateArray":self.maxArr]
            if(WCSession.default().isReachable == true) {
                wcSesh.sendMessage(heartRateArr, replyHandler:  { reply in
                    print(reply)
                    }, errorHandler: { error in
                        print(error)
                })
            }
            
        } else {
            //start a new workout
            self.isMoving = true
            self.startStopButton.setTitle("Stop👊🏽")
            beginWorkout()
            print("beginworkout")
        }
        print("here")
        
    }
    
    func beginWorkout() {
        
        // If we have already started the workout, then do nothing.
        if (workoutSesh != nil) {
            print("already started do nothing")
            return
            
        }
        
        // Configure the workout session.
        let workoutConfig = HKWorkoutConfiguration()
        workoutConfig.activityType = .crossTraining
        workoutConfig.locationType = .indoor
        
        do {
            workoutSesh = try HKWorkoutSession(configuration: workoutConfig)
            workoutSesh?.delegate = self
        } catch {
            fatalError("Unable to create workout session!")
        }
        
        healthStore.start(self.workoutSesh!)
        print("healthstore.startworkoutsesh")
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        
        guard let quantType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePred = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        let pred = NSCompoundPredicate(andPredicateWithSubpredicates:[datePred])
        
        
        let hrQuery = HKAnchoredObjectQuery(type: quantType, predicate: pred, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            //guard let newAnchor = newAnchor else {return}
            //self.anchor = newAnchor
            self.updateHeartRate(sampleObjects)
        }
        
        hrQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            //self.anchor = newAnchor!
            self.updateHeartRate(samples)
        }
        return hrQuery
    }
    
    func updateHeartRate(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        DispatchQueue.main.async {
            guard let sample = heartRateSamples.first else{return}
            let val = sample.quantity.doubleValue(for: self.hrUnit)
            self.label.setText(String(UInt16(val)))
        }
    }
    
}
