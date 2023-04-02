//
//  TabView.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import Foundation
import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            TaskListMainView()
                .tabItem {
                    Image(systemName: "doc")
                    Text("Plan")
                }
            HackathonView()
                .tabItem {
                    Image(systemName: "bolt")
                    Text("Hackathon")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
