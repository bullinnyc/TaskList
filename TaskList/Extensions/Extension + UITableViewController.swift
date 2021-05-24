//
//  Extension + UITableViewController.swift
//  TaskList
//
//  Created by Dmitry Kononchuk on 24.05.2021.
//  Copyright © 2021 Dmitry Kononchuk. All rights reserved.
//

import UIKit

extension UITableViewController {
    
    func editButtonEnabled(_ tasksCount: Int) {
        if tasksCount == 0 {
            editButtonItem.isEnabled = false
        } else {
            editButtonItem.isEnabled = true
        }
    }
    
    func rowIndex(_ row: Int, section: Int = 0) -> IndexPath {
        IndexPath(row: row, section: section)
    }
    
}
