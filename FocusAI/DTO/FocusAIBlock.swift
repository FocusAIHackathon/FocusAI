//
//  FocusAIActivity.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import Foundation
class FocusAIBlock: Codable {
    let uuid, taskID, title: String
    let sdt: Date
    let edt: Date

    enum CodingKeys: String, CodingKey {
        case uuid
        case taskID = "task_id"
        case title, sdt, edt
    }

    init(uuid: String, taskID: String, title: String, sdt: Date, edt: Date) {
        self.uuid = uuid
        self.taskID = taskID
        self.title = title
        self.sdt = sdt
        self.edt = edt
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
}
