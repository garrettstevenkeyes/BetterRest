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
    
    private var idealBedtime: Date? {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            return wakeUp - prediction.actualSleep
        } catch {
            return nil
        }
    }
    
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
    
    private var headerView: some View {
        Text(idealBedtime.map { "Your ideal bedtime is \($0.formatted(date: .omitted, time: .shortened))" } ?? "Your ideal bedtime")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
    }
    
    private var wakePickerView: some View {
        VStack(alignment: .leading, spacing: 0){
            Text("When do you want to wake up?")
                .font(.headline)
            HStack {
                Spacer()
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .padding(.horizontal, 16)
            }
            
        }
    }
    
    private var sleepStepperView: some View {
        VStack(alignment: .leading, spacing: 0){
            Text("Desired amount of sleep")
                .font(.headline)
            
            Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
        }
    }
    
    private var coffeePickerView: some View {
        VStack(alignment: .leading, spacing: 0){
            Text("Daily coffee intake")
                .font(.headline)
            
            Picker("", selection: $coffeeAmount){
                ForEach(1...10, id: \.self){
                    Text("^[\($0) cup](inflect: true)")
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section { } header: { headerView }
                wakePickerView
                sleepStepperView
                coffeePickerView
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("BetterRest")
                        .font(.title)
                        .foregroundStyle(.primary)
                }
            }
            .alert(alertTitle, isPresented: $showingAlert){
                Button("OK"){}
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    ContentView()
}
