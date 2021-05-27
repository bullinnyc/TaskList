//
//  TaskViewController.swift
//  TaskList
//
//  Created by Dmitry Kononchuk on 19.05.2021.
//  Copyright © 2021 Dmitry Kononchuk. All rights reserved.
//

import RealmSwift

class TaskViewController: UITableViewController {
    // MARK: - Public Properties
    var taskList: TaskList!
    //
    
    // MARK: - Private Properties
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentTasks = taskList.tasks.sorted(byKeyPath: "date").filter("isComplete = false")
        completedTasks = taskList.tasks.sorted(byKeyPath: "date").filter("isComplete = true")
        setupUI()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if taskList.tasks.count == 0 {
            return nil
        }
        
        return section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = indexPath.section == 0
            ? currentTasks[indexPath.row]
            : completedTasks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = indexPath.section == 0
            ? currentTasks[indexPath.row]
            : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(task: task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if self.taskList.tasks.count == 0 {
                tableView.reloadSections([0, 1], with: .automatic)
            }
            self.editButtonEnabled(self.taskList.tasks.count)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: task) {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            isDone(true)
        }
        
        let doneTitle = indexPath.section == 0 ? "Done" : "Undone"
        
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { _, _, isDone in
            StorageManager.shared.done(task: task)
            
            let indexPathForCurrentTask = IndexPath(row: self.currentTasks.count - 1, section: 0)
            let indexPathForCompletedTask = IndexPath(row: self.completedTasks.count - 1, section: 1)
            
            let destinationIndexRow = indexPath.section == 0 ? indexPathForCompletedTask : indexPathForCurrentTask
            tableView.moveRow(at: indexPath, to: destinationIndexRow)
            
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = indexPath.section == 0
            ? currentTasks[indexPath.row]
            : completedTasks[indexPath.row]
        
        showAlert(with: task) {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Private Methods
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    private func setupUI() {
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        title = taskList.name
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        tableView.tableFooterView = UIView()
        
        editButtonEnabled(taskList.tasks.count)
    }
}

// MARK: - Ext. Show Alert
extension TaskViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit Task" : "New Task"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")
        
        alert.action(with: task) { newValue, note in
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task: task, name: newValue, note: note)
                completion()
            } else {
                self.saveTask(withName: newValue, andNote: note)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func saveTask(withName name: String, andNote note: String) {
        let task = Task(value: [name, note])
        StorageManager.shared.save(task: task, in: taskList)
        
        guard let index = currentTasks.index(of: task) else { return }
        tableView.insertRows(at: [rowIndex(index)], with: .automatic)
        
        editButtonEnabled(taskList.tasks.count)
    }
}
