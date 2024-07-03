//
//  GameEvent.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/25/21.
//

import Foundation

class GameEvent {
    var task: ()->Void
    var isExecuting: Bool = false
    
    init(_ task: @escaping ()->Void) {
        self.task = task
    }
    
    func execute() {
        isExecuting = true
        task()
    }
}

class EventQueue {
    private var events: [GameEvent] = []
    
    static var sync = EventQueue()
    
    func push(event: GameEvent) {
        events.append(event)
        executeTop()
    }
    
    func pushAndWait(_ task: @escaping ()->Void) {
        let event = GameEvent {
            task()
        }
        push(event: event)
    }
    
    func push(_ task: @escaping ()->Void) {
        pushAndWait {
            task()
            EventQueue.sync.completeTop()
        }
        
    }
    
    func pop(event: GameEvent? = nil) {
        if let event = event {
            events.removeAll { $0 === event }
        } else {
            events.removeFirst()
        }
    }
    
    func executeTop() {
        if let event = events.first {
            if !event.isExecuting {
                event.execute()
            }
        }
    }
    
    func completeTop() {
        pop()
        executeTop()
    }
    
    func complete(event: GameEvent) {
        pop(event: event)
        executeTop()
    }
}
