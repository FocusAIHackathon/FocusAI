//
//  ScheduleResponse.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/2/23.
//

import Foundation
class ScheduleResponse: Codable {
    let new_blocks: [FocusAIBlock]
    let status: String

    init(new_blocks: [FocusAIBlock], status: String) {
        self.new_blocks = new_blocks
        self.status = status
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

    static func fromJsonData(data: Data) -> ScheduleResponse? {
        let decoder = GetDefaultJsonDecoder()
        if let sr = try? decoder.decode(ScheduleResponse.self, from: data) {
            return sr;
        } else {
            return nil
        }
    }
}
