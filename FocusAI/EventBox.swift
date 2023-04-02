//
//  HourBox.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import Foundation
import SwiftUI
import EventKit
struct EventBox: View {
    let event: EKEvent
    var body: some View {
        ZStack() {
            Rectangle()
                .frame(width: UIScreen.main.bounds.width, height:
                        GetHeightFromDuration()
                        )
                .foregroundColor(.blue)
                .opacity(0.80)

            VStack() {
                HStack() {
                    Rectangle()
                        .fill(.black)
                        .frame(width:120, height: GetHeightFromDuration())
                        .overlay() {
                            VStack() {
                                Text(event.startDate.toDayString())
                                    .padding(.bottom, -5)
                                Divider()
                                Text(event.startDate.toTimeString() + " - " +  event.endDate.toTimeString())
                                    .padding(.top, -2)
                            }
                        }
                        .foregroundColor(.white)


                    Text(event.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .foregroundColor(.white)
                        .bold()
                }

            }

        }

    }
}

struct HourBox_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            EventBox(event: GetMockEvent())
        }
    }
}

func GetDurationInMins(_ d1: Date, _ d2: Date) -> Int {
    let differenceInSeconds = d2.timeIntervalSince(d1)
    let differenceInMinutes = Int(differenceInSeconds / 60)
    return differenceInMinutes
}

func GetHeightFromDuration() -> CGFloat {
//    let actual = CGFloat(GetDurationInMins(d1, d2))/2
    return 60
}
