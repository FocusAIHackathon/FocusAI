//
//  ScheduleFailure.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/2/23.
//

import Foundation
class ScheduleFailure: Codable {
    let code: Int
    let msg: String

    init(code: Int, msg: String) {
        self.code = code
        self.msg = msg
    }

    func toJson() -> String {
        do {
            let encoder = GetDefaultEncoder()
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            return "{}"
        } catch {
            print(error.localizedDescription)
            return "{}"
        }
    }

    static func fromJsonData(data: Data) -> ScheduleFailure? {
        let decoder = GetDefaultJsonDecoder()
        if let sr = try? decoder.decode(ScheduleFailure.self, from: data) {
            return sr;
        } else {
            return nil
        }
    }
}
