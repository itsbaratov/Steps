//
//  SettingsView.swift
//  Steps
//
//  Created by Nurbek Baratov on 16/11/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyStepGoal") private var dailyStepGoal = 10000 // Default value
    @AppStorage("distanceUnits") private var distanceUnits = "Kilometers"
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Daily Step Goal")) {
                        Stepper(value: $dailyStepGoal, in: 1000...30000, step: 1000) {
                            HStack {
                                Text("Your goal")
                                Spacer()
                                Text("\(dailyStepGoal) steps")
                            }
                        }
                    }
                    
                    Section(header: Text("Distance Units")) {
                        Picker("Distance Units", selection: $distanceUnits) {
                            Text("Miles").tag("Miles")
                            Text("Kilometers").tag("Kilometers")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section {
                        Link("Get Help", destination: URL(string: "https://support.example.com")!)
                        NavigationLink(destination: PremiumFeaturesView()) {
                            Text("Pedometer++ Premium")
                        }
                    }
                }
                
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

// Placeholder view for premium features. Implement this according to your app's needs.
struct PremiumFeaturesView: View {
    var body: some View {
        Text("Premium Features Information")
    }
}
#Preview {
    SettingsView()
}
