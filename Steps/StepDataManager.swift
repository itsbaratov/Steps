//
//  StepDataManager.swift
//  Steps
//
//  Created by Nurbek Baratov on 16/11/23.
//

import HealthKit

class StepDataManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var stepsData = [StepData]()

    // Call this method to request authorization from the user
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let typesToRead: Set = [stepType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("Authorization failed with error: \(error.localizedDescription)")
            }
            completion(success)
        }
    }

    // Call this method to fetch step count data
    func fetchStepCountData() {
            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            var dateComponents = DateComponents()
            dateComponents.day = -7

            let startDate = Calendar.current.date(byAdding: dateComponents, to: startOfDay)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
            
            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: startOfDay,
                intervalComponents: DateComponents(day: 1)
            )
            
            query.initialResultsHandler = { [weak self] query, statisticsCollection, error in
                if let error = error {
                    print("Error fetching steps: \(error.localizedDescription)")
                    return
                }
                
                var stepDataArray = [StepData]()
                statisticsCollection?.enumerateStatistics(from: startDate, to: now) { statistics, stop in
                    let count = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    let components = Calendar.current.dateComponents([.day, .month, .year], from: statistics.startDate)
                    if let day = components.day, let month = components.month {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "E"
                        let dayString = dateFormatter.string(from: statistics.startDate)
                        let distance = count / 2000 // example conversion, replace with actual distance calculation if available
                        let goalAchieved = count >= 10000 // example goal, replace with actual logic if needed
                        
                        let stepData = StepData(day: "\(dayString) \(day)/\(month)", steps: Int(count), distance: distance, goalAchieved: goalAchieved)
                        stepDataArray.append(stepData)
                    }
                }
                
                DispatchQueue.main.async {
                    self?.stepsData = stepDataArray
                }
            }
            
            healthStore.execute(query)
        }
    }
