//
//  TaskAEView.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import Foundation
import SwiftUI

struct TaskAE: View {
    var dismissAction: () -> Void

    @State private var apiCallInProgress: Bool = false

    @State private var scheduleError: String = ""

    @State private var taskType: FocusAITaskTypes = .task
    @State private var taskName: String = ""
    @State private var selectedEffort: EffortOption = EffortOption(mins: 60)
    @State private var deadline: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    @State private var startDate: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @State private var endDate: Date = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
    private let taskTypes: [FocusAITaskTypes] = [.task, .activity]
    private let effortOptions: [EffortOption] = EffortOption.GetAllEffortOptions()
    var body: some View {
        VStack {
            HStack {
                Text("Add New " + taskType.rawValue)
                    .font(.title)
                    .padding(.top, 10)
            }

            TextField("Title", text: $taskName)
                .padding()
               .textFieldStyle(DefaultTextFieldStyle())
               .font(.title2)

            HStack {
                Text("Type")
                    .padding(.leading, 20)
                Spacer()
                Picker(taskType.rawValue, selection: $taskType) {
                    ForEach(taskTypes, id: \.self) { tt in
                        Text(tt.rawValue)
                    }
                }
                .padding(.trailing, 10)
            }

            if self.taskType == .task {
                VStack {
                    HStack {
                        Text("Pick Estimated Time Effort")
                            .padding(.leading, 20)
                        Spacer()
                        Picker("Choose Estimated Time", selection: $selectedEffort) {
                            ForEach(effortOptions, id: \.self) { eo in
                                Text(eo.label)
                            }
                        }
                        .padding(.trailing, 10)
                    }
                    DatePicker(selection: $deadline) {
                        Text("Deadline")
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                }
            } else {
                VStack {
                    DatePicker(selection: $startDate) {
                        Text("Start Date")
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)

                    DatePicker(selection: $endDate) {
                        Text("End Date")
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                }
            }
            if scheduleError != "" {
                VStack {
                    Text(scheduleError)
                        .padding()
                        .foregroundColor(.red)
                        .bold()
                }
            }




            Button(action: addTask) {
                if (apiCallInProgress) {
                    Text("Adding...")
                        .frame(maxWidth: .infinity)
                        .font(.title3)
                } else {
                    Text("Add " + self.taskType.rawValue)
                        .frame(maxWidth: .infinity)
                        .font(.title3)
                }
            }
            .padding(8)
            .background(Color.blue)
            .cornerRadius(30)
            .shadow(radius: 8)
            .foregroundColor(.white)
            .frame(width: 150, height: 150)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    func addTask() {
        if (self.apiCallInProgress) {
            return
        }
        self.apiCallInProgress = true
        // get all blocks
        var blocks = GetAllBlocks()
        var tasks = GetAllTasks()
        var current_task: FocusAITask!
        switch self.taskType {
        case .task:
            current_task = FocusAITask(taskId: UUID().uuidString, title: self.taskName, remainingEffortMins: self.selectedEffort.mins, totalEffortMins: self.selectedEffort.mins, deadline: self.deadline)
            print("will add a task", current_task.toJson())
            tasks.append(current_task)

        case .activity:
            let uuid = UUID().uuidString
            let block = FocusAIBlock(uuid: uuid, taskID: uuid, title: self.taskName, sdt: self.startDate, edt: self.endDate)
            print("will add a bloc", block.toJson())
            blocks.append(block)
        }
        let scheduleRequest = ScheduleRequest(blocks: blocks, tasks: tasks)
        print("will make scheduling request")
        let payload = scheduleRequest.toJson()
        print(payload)

        // let's make API call
        var request = URLRequest(url: URL(string: "https://focusai-in.azurewebsites.net/api/reschedule")!)
        request.httpMethod = "POST"
        request.httpBody = try? scheduleRequest.toJsonData()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // handle the response
            var failed: Bool = false
            guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
            }

            if let error = error {
                print("Error: \(error)")
                return
            } else if httpResponse.statusCode > 200 {
                print("Success: Status code \(httpResponse.statusCode)")
                // Process the response data here
                failed = true
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if failed {

                guard let sf = ScheduleFailure.fromJsonData(data: data) else {
                    print("failed to convert to Schedule Failure")
                    return
                }
                print(sf)
                DispatchQueue.main.async {
                    self.apiCallInProgress = false
                    self.scheduleError = sf.msg
                    if self.taskType == .task {
                        if self.scheduleError.contains(current_task.title) {
                            self.scheduleError = "It's not possible to schedule this task and meet it's deadline. It's simply too big"
                        }
                    }
                }


            } else {
                // parse the response data
                guard let sr = ScheduleResponse.fromJsonData(data: data) else {
                    print("failed to convert to Schedule Response")
                    return
                }
                print(sr)
                DispatchQueue.main.async {
                    self.apiCallInProgress = false
                    AddToTasks(task: current_task)
                    AddToCal(new_blocks: sr.new_blocks)
                    self.dismissAction()
                }
            }
        }
        task.resume()

    }
}

struct TaskAE_Preview: PreviewProvider {
    static var previews: some View {
        ZStack {
            TaskAE(dismissAction: {
            })
        }
    }
}
