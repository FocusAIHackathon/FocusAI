//
//  HackathonControl.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import Foundation
import SwiftUI
import UserNotifications
import EventKit
import CoreData


struct HackathonView: View {
    var body: some View {
        VStack {

            Button(action: ClearFocusAIScheduling) {
                Text("Clear Focus.AI Schedulings")
            }
            .frame(width: 300, height: 60)
            .border(.blue)
            .padding(10)


            Button(action: SendDailyPlanReminder) {
                Text("Send Daily Plan Notification")
            }
            .frame(width: 300, height: 60)
            .border(.blue)
            .padding(10)

            Button(action: {}) {
                Text("Send Task Start Notification")
            }
            .frame(width: 300, height: 60)
            .border(.blue)
            .padding(10)


            Button(action: requestPermission) {
                Text("Request Notification Permission")
            }
            .frame(width: 300, height: 60)
            .border(.blue)
            .padding(10)
        }
    }
}

struct HackathonView_Preview: PreviewProvider {
    static var previews: some View {
        ZStack {
            HackathonView()
        }
    }
}

func ClearFocusAIScheduling() {
    /// delete existing stuff from calendar
    let eventStore = EKEventStore()
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: Date())
    let endOfDay = calendar.date(byAdding: .day, value: 10, to: startOfDay)!
    let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
    let eventsToDelete = eventStore.events(matching: predicate).filter {
        guard let notes = $0.notes else { return false}
        return notes.starts(with: "focus-ai-")
    }
    for ev in eventsToDelete {
        do {
            try eventStore.remove(ev, span: .thisEvent, commit: false)
        }
        catch {
            print("Error whilte deleting \(error)")
        }
    }

    do {
        try eventStore.commit()
    }
    catch {
        print("Error whilte deleting \(error)")
    }

    /// delete core data
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FocusAITaskCDM")
    let context = PersistenceController.shared.container.viewContext
    do {
        // Execute fetch request using the managed object context
        let fetchedResults = try context.fetch(fetchRequest) as! [FocusAITaskCDM]

        // Process the fetched results
        for focusAITaskCDM in fetchedResults {
            context.delete(focusAITaskCDM)
        }
        try context.save()
    } catch let error as NSError {
        // Handle the error
        print("Fetch failed: \(error.localizedDescription)")
    }

    print ("all cleared !! ")
}

func SendDailyPlanReminder() {
    let content = UNMutableNotificationContent()
    content.title = "Review your plan for the day"
    content.body = "Hi Gaurav! Now is a good time to review your plan for today and any new tasks that you might need to do"
    content.sound = UNNotificationSound.default

    let positiveAction = UNNotificationAction(identifier: "PlanNotificationCategory.go", title: "Sure", options: [])
    let dismissAction = UNNotificationAction(identifier: "PlanNotificationCategory.dismiss", title: "Dismiss", options: [.destructive])

    let category = UNNotificationCategory(identifier: "PlanNotificationCategory", actions: [positiveAction, dismissAction], intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([category])

    content.categoryIdentifier = "PlanNotificationCategory"

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error.localizedDescription)")
        } else {
            print("Notification scheduled successfully")
        }
    }
}

func requestPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Error requesting notification permission: \(error.localizedDescription)")
        } else if granted {
            print("Notification permission granted")
        } else {
            print("Notification permission denied")
        }
    }
}
