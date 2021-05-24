//
//  DataManager.swift
//  TaskList
//
//  Created by Dmitry Kononchuk on 19.05.2021.
//  Copyright © 2021 Dmitry Kononchuk. All rights reserved.
//

import Foundation

class DataManager {
    
    // MARK: - Public Properties
    static let shared = DataManager()
    //
    
    // MARK: - Private Initializers
    private init() {}
    //
    
    // MARK: - Public Properties
    func createTempData(_ completion: @escaping () -> Void) {
        if !UserDefaults.standard.bool(forKey: "DefaultTaskList") {
            UserDefaults.standard.set(true, forKey: "DefaultTaskList")
            
            // Create TaskList
            let shoppingList = TaskList()
            shoppingList.name = "Shopping List"
            
            let moviesList = TaskList()
            moviesList.name = "Movies List"
            
            // Create Task in TaskList
            let milk = Task(value: ["name": "Milk", "note": "1L", "isComplete": true])
            let bread = Task(value: ["name": "Bread", "note": "One"])
            let apple = Task(value: ["name": "Apple", "note": "2Kg"])
            
            shoppingList.tasks.append(milk)
            shoppingList.tasks.insert(contentsOf: [bread, apple], at: 1)
            
            DispatchQueue.main.async {
                StorageManager.shared.save(taskLists: [shoppingList, moviesList])
                completion()
            }
        }
    }
    
}
