//
//  FocusAIApp.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import SwiftUI

@main
struct FocusAIApp: App {
    let persistenceController = PersistenceController.shared
    let notificationCenter: MyNotificationCenter!
    init() {
        self.notificationCenter = MyNotificationCenter()
    }

    var body: some Scene {
        WindowGroup {
//            TaskListMainView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


class MyNotificationCenter {
    let notificationCenter = UNUserNotificationCenter.current()
    let delegate = NotificationDelegate()

    init() {
        notificationCenter.delegate = delegate
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // Show the notification when it is received while the app is running
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "PlanNotificationCategory.go":
            print("go pressed")
        case "PlanNotificationCategory.dismiss":
            print("dismiss pressed")
        default:
            print("default pressed ", response.actionIdentifier)
        }
        completionHandler()
    }
}
