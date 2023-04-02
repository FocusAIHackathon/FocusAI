//
//  EffortOption.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import Foundation
class EffortOption: Hashable {
    var mins: Int
    var label: String
    init(mins: Int) {
        self.mins = mins
        let hours = mins/60
        let rem = mins % 60
        if hours == 0 {
            self.label = "30 mins"
        } else if hours == 1 && rem == 0 {
            self.label = "1 hour"
        }  else {
            self.label = String(format: "%.1f", (Double(mins)/60.0)) + " hours"
        }
    }

    func hash(into hasher: inout Hasher) {
            hasher.combine(mins)
    }

    static func GetAllEffortOptions() -> [EffortOption] {
        var retval: [EffortOption] = []
        for i in stride(from: 30, to: 3000, by: 30) {
            retval.append(EffortOption(mins: i))
        }
        return retval
    }
    static func == (lhs: EffortOption, rhs: EffortOption) -> Bool {
        return lhs.mins == rhs.mins
    }


}
