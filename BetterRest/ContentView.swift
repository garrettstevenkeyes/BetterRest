//
//  ContentView.swift
//  BetterRest
//
//  Created by Garrett Keyes on 11/10/25.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 8
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert = false
    @State private var headerText: Date = defaultSleepTime
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    static var defaultSleepTime : Date {
        var components = DateComponents()
        components.hour = 21
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    var body: some View {
        
        NavigationStack {
            Form {
                Section {
                    // Empty content; this is just a header row
                } header: {
                    Text("Your ideal bedtime is \(headerText.formatted(date: .omitted, time: .shortened))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    HStack {
                        Spacer()
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .padding(.horizontal, 16)
                            .onChange(of: wakeUp){ _, __ in
                                calculateBedtime()
                            }
                    }
                    
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) { _, __ in
                            calculateBedtime()
                        }
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Picker("", selection: $coffeeAmount){
                        ForEach(1...10, id: \.self){
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                    .onChange(of: coffeeAmount) { _, __ in
                        calculateBedtime()
                    }
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert){
                Button("OK"){}
            } message: {
                Text(alertMessage)
            }
        }
    }
        
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                                                  
            headerText = wakeUp - prediction.actualSleep
        } catch {
            alertTitle = "Error"
            alertMessage = "Failed to make a prediction."
            showingAlert.toggle()
        }

    }
}

#Preview {
    ContentView()
}
