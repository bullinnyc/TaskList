//
//  StorageManager.swift
//  TaskList
//
//  Created by Dmitry Kononchuk on 19.05.2021.
//  Copyright © 2021 Dmitry Kononchuk. All rights reserved.
//

import RealmSwift

class StorageManager {
    
    // MARK: - Public properties
    static let shared = StorageManager()
    
    let localRealm = try! Realm()
    
    // MARK: - Private Initializers
    private init() {}
    //
    
    // MARK: - Work with TaskLists
    func save(taskLists: [TaskList]) {
        write {
            localRealm.add(taskLists)
        }
    }
    
    func save(taskList: TaskList) {
        write {
            localRealm.add(taskList)
        }
    }
    
    func delete(taskList: TaskList) {
        write {
            localRealm.delete(taskList.tasks)
            localRealm.delete(taskList)
        }
    }
    
    func edit(taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }
    
    func done(taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    // MARK: - Work with Tasks
    func save(task: Task, in taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }
    
    func delete(task: Task) {
        write {
            localRealm.delete(task)
        }
    }
    
    func edit(task: Task, name: String, note: String) {
        write {
            task.name = name
            task.note = note
        }
    }
    
    func done(task: Task) {
        write {
            task.isComplete.toggle()
            task.date = Date()
        }
    }
    
    // MARK: - Private Methods
    private func write(_ completion: () -> Void) {
        do {
            try localRealm.write { completion() }
        } catch let error {
            print(error)
        }
    }
    
}
