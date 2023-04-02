//
//  util.swift
//  FocusAI
//
//  Created by Gaurav Kalele - Vendor on 4/1/23.
//

import CoreData
import Foundation
import EventKit

func GetMockEvent() -> EKEvent {
    let eventStore = EKEventStore()
    let event = EKEvent(eventStore: eventStore)

    // Set the properties of the event
    event.title = "My Event"
    event.notes = "This is a fake event"
    event.calendar = eventStore.defaultCalendarForNewEvents
    event.startDate = Date()
    event.endDate = Date().addingTimeInterval(60 * 60 * 1) // End time is 1 hour after start time
    return event
}


func GetDefaultEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    encoder.dateEncodingStrategy = .formatted(dateFormatter)
    return encoder
}

func GetDefaultJsonDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    return decoder
}

func GetAllBlocks() -> [FocusAIBlock] {
    var retval:[FocusAIBlock] = []
    let eventStore = EKEventStore()
    // Assuming we have access
    // not prod ready
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: Date())
    let endOfDay = calendar.date(byAdding: .day, value: 2, to: startOfDay)!
    /*
    let today = Date()
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    let predicate = eventStore.predicateForEvents(withStart: today, end: tomorrow, calendars: nil)
    */
    let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
    let events = eventStore.events(matching: predicate).filter {
        guard let notes = $0.notes else { return true}
        return (!notes.starts(with: "focus-ai-"))
    }
    for ev in events {
        let block = FocusAIBlock(uuid: ev.eventIdentifier, taskID: ev.eventIdentifier, title: ev.title, sdt: ev.startDate, edt: ev.endDate)
        retval.append(block)
    }
    return retval
}

func GetAllTasks() -> [FocusAITask] {
    var retval:[FocusAITask] = []
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FocusAITaskCDM")
    let context = PersistenceController.shared.container.viewContext
    do {
        // Execute fetch request using the managed object context
        let fetchedResults = try context.fetch(fetchRequest) as! [FocusAITaskCDM]

        // Process the fetched results
        for focusAITaskCDM in fetchedResults {
            let focusAITask = FocusAITask(taskId: focusAITaskCDM.taskID!, title: focusAITaskCDM.title!, remainingEffortMins: Int(focusAITaskCDM.remainingEffortMins), totalEffortMins: Int(focusAITaskCDM.totalEffortMins), deadline: focusAITaskCDM.deadline!)
            retval.append(focusAITask)
        }
    } catch let error as NSError {
        // Handle the error
        print("Fetch failed: \(error.localizedDescription)")
    }
    return retval
}

/// make sure to call from main thread
func AddToTasks(task: FocusAITask) {
    let context = PersistenceController.shared.container.viewContext
    let new_task_cdm = FocusAITaskCDM(context: context)
    new_task_cdm.title = task.title
    new_task_cdm.deadline = task.deadline
    new_task_cdm.totalEffortMins = Int32(task.totalEffortMins)
    new_task_cdm.remainingEffortMins = Int32(task.remainingEffortMins)
    new_task_cdm.taskID = task.taskID
    do {
        try context.save()
      } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
}


func GetAllFocusAIEvents() -> [EKEvent] {
    let eventStore = EKEventStore()
    // Assuming we have access
    // not prod ready
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: Date())
    let endOfDay = calendar.date(byAdding: .day, value: 10, to: startOfDay)!
    let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
    let events = eventStore.events(matching: predicate).filter {
        guard let notes = $0.notes else { return false}
        return notes.starts(with: "focus-ai-")
    }
    return events
}

/// call from main thread
func AddToCal(new_blocks: [FocusAIBlock]) {
    /// delete existing stuff from calendar
    let eventStore = EKEventStore()
    let calendarx = Calendar.current
    let startOfDay = calendarx.startOfDay(for: Date())
    let endOfDay = calendarx.date(byAdding: .day, value: 10, to: startOfDay)!
    let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
    let eventsToDelete = eventStore.events(matching: predicate).filter {
        guard let notes = $0.notes else { return false}
        return notes.starts(with: "focus-ai-")
    }

    for ev in eventsToDelete {
        do {
            try eventStore.remove(ev, span: .thisEvent, commit: false)
        }
        catch {
            print("Error whilte deleting \(error)")
        }
    }

    // Get the calendar to add the event to
    let calendars = eventStore.calendars(for: .event)
    let calendar = calendars.filter { $0.title == "gskalele@dons.usfca.edu" }.first
    guard let calendar = calendar else { return }


    for block in new_blocks {
        let ev = EKEvent(eventStore: eventStore)
        ev.notes = block.uuid + " do not remove "
        ev.title = block.title
        ev.startDate = block.sdt
        ev.endDate = block.edt
        ev.calendar = calendar
        do {
            try eventStore.save(ev, span: .thisEvent, commit: false)
        }
        catch {
            print("Error whilte adding event \(error)")
        }
    }
    do {
        try eventStore.commit()
    }
    catch {
        print("Error whilte deleting \(error)")
    }
}
