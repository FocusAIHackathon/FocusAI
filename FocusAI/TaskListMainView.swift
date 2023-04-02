//
//  TaskListMainView.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import Foundation
import SwiftUI
import EventKit

struct TaskListMainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate: Date = Date()
    @State private var events: [EKEvent] = []
    @State private var datePickerId: Int = 0
    @State private var showAddEditTask: Bool = false

    var body: some View {
        ZStack () {
            VStack () {
                Text("Focus.AI: Current Plan")
                    .font(.title)
                DatePicker(selection: $selectedDate, displayedComponents: .date) {
                    Text("Select a date")
                }
                .id(datePickerId)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                Divider()
                    .padding(.top, 10)
                ScrollView {
                    DayTimelineView(date: selectedDate, events: events)
                }

            }
            .onAppear {
                fetchEvents(for: selectedDate)
            }
            .onChange(of: selectedDate) { newDate in
                fetchEvents(for: newDate)
                datePickerId = datePickerId + 1
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .preferredColorScheme(.light)



            VStack {
                Spacer()
                HStack {
                    Button(action: addTask) {
                        Text("Add New")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(8)
                    .background(Color.blue)
                    .cornerRadius(30)
                    .shadow(radius: 8)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 120)
                }
                .padding(.bottom, -20)
            }
            .sheet(isPresented: $showAddEditTask) {
                TaskAE(dismissAction: {
                    showAddEditTask = false // Dismiss the sheet
                })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .edgesIgnoringSafeArea(.bottom)
                    .presentationDetents([.fraction(0.60), .fraction(0.80)])
            }
        }
    }

    func addTask() {
        self.showAddEditTask = true
    }

    func fetchEvents(for date: Date) {
        print("fetch event called")
        let eventStore = EKEventStore()

        // Request permission to access the user's calendar
        eventStore.requestAccess(to: .event) { granted, error in
            if granted, error == nil {
                print("got permission")
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                /*
                let today = Date()
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
                let predicate = eventStore.predicateForEvents(withStart: today, end: tomorrow, calendars: nil)
                */
                let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
                let events = eventStore.events(matching: predicate)
                print("events", events)

                DispatchQueue.main.async {
                    self.events = events
                }
            } else {
                print("didn't get permission", error ?? "")
            }
        }
    }
    
}

struct TaskListMainView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            TaskListMainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
