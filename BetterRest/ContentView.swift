//
//  ContentView.swift
//  BetterRest
//
//  Created by Aziz Baubaid on 28.06.23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    //wakeUp: when user wants to wake up. sleepAmount: how much user would like
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    //for the alert
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired amount of sleep")
                    .font(.headline)
                
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                
                Text("Daily coffee intake")
                    .font(.headline)
                
                Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculatedBedtime)
            }
            
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculatedBedtime() {
        do {
            //the use of MLModelConfiguration is optional, and in many cases, you can create an MLModel instance without explicitly configuring it. The MLModelConfiguration class provides flexibility for advanced use cases where specific configurations or metadata need to be set.
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            // Core ML can throw errors in two places: loading the model as seen below, but also when we ask for predictions.
            //components are always optional values. we wrap them carefully (nil-coalescing)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            //converting to seconds
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time:.shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
