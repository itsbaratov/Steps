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
    var day: String
    var steps: Int
    var distance: Double
    var goalAchieved: Bool
}


struct ContentView: View {
    @StateObject var stepDataManager = StepDataManager() // Observe the StepDataManager instance
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with current step count and distance
                VStack {
                    Text("0")
                        .font(.system(size: 80))
                        .fontWeight(.heavy)
                    Text("0.0 km")
                        .font(.title2)
                    Text("0")
                        .font(.caption)
                }
                .padding(.top)
                
                // Divider line
                Divider()
                    .padding(.vertical)
                
                // ScrollView for horizontal scrolling of the histogram
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Chart {
                            ForEach(stepDataManager.stepsData.indices, id: \.self) { index in let data = stepDataManager.stepsData[index]
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
                                
                            }
                        }
                        // This hides the Y-axis grid lines
                        .chartYAxis(.hidden)
                        
                        // If you want to hide the X-axis grid lines as well, uncomment the following line
                        // .chartXAxis(.hidden)
                        .frame(minWidth: UIScreen.main.bounds.width - 1) // Adjust padding as necessary
                    }
                }


                
                // Summary view with total steps, distance, and goal percentage
                HStack {
                    Text("36.892")
                        .fontWeight(.bold)
                    Spacer()
                    Text("27.9 km")
                        .fontWeight(.bold)
                    Spacer()
                    Text("52% of Goal")
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                
                .padding()
                // Tab bar for navigation
                Spacer()
                
                HStack {
                    Spacer()
                    Image(systemName: "figure.walk")
                    Spacer()
                    Image(systemName: "badge.plus.radiowaves.right")
                    Spacer()
                    Image(systemName: "gear")
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
