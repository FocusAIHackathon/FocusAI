//
//  Task.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import Foundation
enum FocusAITaskTypes: String {
    case task = "Task"
    case activity = "Activity"
}
class FocusAITask: Codable {
    let taskID, title: String
    let remainingEffortMins: Int
    let totalEffortMins: Int
    let deadline: Date

    enum CodingKeys: String, CodingKey {
        case taskID = "task_id"
        case title
        case remainingEffortMins = "remaining_effort_mins"
        case totalEffortMins = "total_effort_mins"
        case deadline
    }

    init(taskId: String, title: String, remainingEffortMins: Int, totalEffortMins: Int, deadline: Date) {
        self.taskID = taskId
        self.title = title
        self.remainingEffortMins = remainingEffortMins
        self.totalEffortMins = totalEffortMins
        self.deadline = deadline
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

