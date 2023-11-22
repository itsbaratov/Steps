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

        // Query to find the earliest date with step data
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let earliestStepsQuery = HKSampleQuery(sampleType: stepType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] (query, results, error) in
            guard let earliestStepSample = results?.first as? HKQuantitySample else {
                print("No steps data found")
                return
            }

            let earliestDate = earliestStepSample.startDate
            // Now perform the actual query for the chart data starting from this earliestDate
            self?.fetchChartData(from: earliestDate)
        }

        healthStore.execute(earliestStepsQuery)
    }

    func fetchChartData(from startDate: Date) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: now,
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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E dd/MM"
                let dayString = dateFormatter.string(from: statistics.startDate)
                
                let distance = count / 2000 // example conversion
                let goalAchieved = count >= 10000 // example goal
                
                let stepData = StepData(date: statistics.startDate, day: dayString, steps: Int(count), distance: distance, goalAchieved: goalAchieved)
                            stepDataArray.append(stepData)
            }
            
            DispatchQueue.main.async {
                self?.stepsData = stepDataArray.sorted(by: { $0.date < $1.date })
            }
        }


        healthStore.execute(query)
    }


    }




