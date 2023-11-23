//
//  ContentView.swift
//  Steps
//
//  Created by Nurbek Baratov on 16/11/23.
//

import SwiftUI
import Charts
import HealthKit

// Sample data structure for a day's step data
struct StepData {
    var date: Date
    var day: String
    var steps: Int
    var distance: Double
    var goalAchieved: Bool
}


struct ContentView: View {
    @StateObject var stepDataManager = StepDataManager() // Observe the StepDataManager instance
    var firstWeekSummary: (steps: Int, distance: Double, goalPercentage: Double) {
            let firstWeekData = stepDataManager.stepsData.prefix(7)
            let totalSteps = firstWeekData.reduce(0) { $0 + $1.steps }
            let totalDistance = firstWeekData.reduce(0.0) { $0 + $1.distance }
            let goalPercentage = firstWeekData.reduce(0.0) { $0 + ($1.goalAchieved ? 1 : 0) } / 7.0 * 100
            return (totalSteps, totalDistance, goalPercentage)
        }
    
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with current step count and distance
                VStack {
                    Text("4552")
                        .font(.system(size: 80))
                        .fontWeight(.heavy)
                    Text("3 km")
                        .font(.title2)
                }
                .padding(.top)
                
                // Divider line
                Divider()
                    .padding(.vertical)
                
                // ScrollView for horizontal scrolling of the histogram
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        // Calculate the width based on the total number of entries
                        // You can adjust the multiplier to increase or decrease the width of each bar
                        let barWidth: CGFloat = 56 // Example width for each bar
                        let chartWidth = barWidth * CGFloat(stepDataManager.stepsData.count)
                        
                        Chart {
                            ForEach(stepDataManager.stepsData.indices, id: \.self) { index in
                                let data = stepDataManager.stepsData[index]
                                
                                
                                BarMark(
                                    x: .value("Day", data.day),
                                    y: .value("Steps", data.steps)
                                )
                                .foregroundStyle(data.goalAchieved ? .green : .red)
                                .cornerRadius(8)
                                .annotation(position: .top, alignment: .center) {
                                    Text("\(data.steps)")
                                        .font(.caption)
                                        .foregroundColor(data.goalAchieved ? .green : .red)
                                }
                                .annotation(position: .overlay, alignment: .center) {
                                            VStack {
                                                Spacer() // Pushes the text to the bottom of the bar
                                                Text(String(format: "%.1f km", data.distance))
                                                    .font(.caption)
                                                    .foregroundColor(.white) // Use a color that is visible on top of the bar color
                                                    .padding(.bottom, 4) // Adjust the padding to fine-tune the exact position
                                            }
                                            .frame(maxHeight: .infinity, alignment: .bottom) // Use maxHeight to allow the Spacer to push the text to the bottom
                                        }
                            }
                        }
                        
                        .chartYAxis(.hidden)
                        .frame(width: chartWidth) // Dynamic width based on the number of data points
                    }
                }
                .padding(.leading, 0) // Adjust this as needed to align the bars to the leading edge if necessary
                HStack {
                                Text("\(firstWeekSummary.steps)")
                                    .fontWeight(.bold)
                                Spacer()
                                Text(String(format: "%.1f km", firstWeekSummary.distance))
                                    .fontWeight(.bold)
                                Spacer()
                                Text(String(format: "%.0f%% of Goal", firstWeekSummary.goalPercentage))
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal)


                
                // Summary view with total steps, distance, and goal percentage
                
                
                .padding()
                // Tab bar for navigation
                Spacer()
                
                HStack {
                    Spacer()
                    Image(systemName: "figure.walk")
                    Spacer()
                    Spacer()
                    Image(systemName: "gearshape.fill")
                    Spacer()
                }
                .padding(.top)
                .background(Color.gray.opacity(0.1))
            }
            .navigationTitle("Pedometer++")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
                stepDataManager.requestAuthorization { authorized in
                    if authorized {
                        stepDataManager.fetchStepCountData()
                    } else {
                        print("HealthKit authorization was denied by the user.")
                    }
                }
            }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
