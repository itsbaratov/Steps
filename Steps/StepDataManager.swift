//
//  StepDataManager.swift
//  Steps
//
//  Created by Nurbek Baratov on 16/11/23.
//

import HealthKit

class StepDataManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    // Check if HealthKit is available on this device
    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    // Request permission to access the required data
    func requestAuthorization() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let typesToRead: Set = [stepType]
        
        // Check for HealthKit availability before requesting authorization
        guard isHealthKitAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if !success {
                // Handle the error here.
                print("Permission denied by user")
            }
        }
    }
}
