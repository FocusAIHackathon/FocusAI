//
//  DayTimeLineView.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import Foundation
import SwiftUI
import EventKit
struct DayTimelineView: View {
    let date: Date
    let events: [EKEvent]

    let hours = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]

    var body: some View {
        VStack {
            if events.isEmpty {
                Text("No events")
            } else {
                ForEach(events, id: \.eventIdentifier) { event in
                    EventBox(event: event)
                        .padding(.bottom, -7)
                }
            }
        }
    }
}

struct DayTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            DayTimelineView(date: Date(), events: [GetMockEvent(), GetMockEvent(), GetMockEvent(), GetMockEvent()])
        }
    }
}

