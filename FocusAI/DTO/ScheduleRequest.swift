//
//  ScheduleRequest.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/2/23.
//

import Foundation

class ScheduleRequest: Codable {
    let blocks: [FocusAIBlock]
    let tasks: [FocusAITask]

    init(blocks: [FocusAIBlock], tasks: [FocusAITask]) {
        self.blocks = blocks
        self.tasks = tasks
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

    func toJsonData() throws -> Data? {
        let encoder = GetDefaultEncoder()
        let jsonData = try encoder.encode(self)
        return jsonData
    }
}
