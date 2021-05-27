//
//  TaskList.swift
//  TaskList
//
//  Created by Dmitry Kononchuk on 19.05.2021.
//  Copyright © 2021 Dmitry Kononchuk. All rights reserved.
//

import RealmSwift

class TaskList: Object {
    // MARK: - Public Properties
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    
    let tasks = List<Task>()
}
