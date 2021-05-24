//
//  TaskListViewController.swift
//  TaskList
//
//  Created by Dmitry Kononchuk on 19.05.2021.
//  Copyright © 2021 Dmitry Kononchuk. All rights reserved.
//

import RealmSwift

class TaskListViewController: UITableViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    //
    
    // MARK: - Private Properties
    private var taskLists: Results<TaskList>!
    //
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTempData()
        taskLists = StorageManager.shared.localRealm.objects(TaskList.self).sorted(byKeyPath: "name")
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let taskList = taskLists[indexPath.row]
        cell.configure(with: taskList)
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(taskList: taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.editButtonEnabled(self.taskLists.count)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: taskList) {
                guard let index = self.taskLists.index(of: taskList) else { return }
                let rowIndex = self.rowIndex(index)
                
                let startIndex = rowIndex.row < indexPath.row ? rowIndex.row : indexPath.row
                let endIndex = rowIndex.row < indexPath.row ? indexPath.row : rowIndex.row
                
                for row in startIndex ... endIndex {
                    self.tableView.reloadRows(at: [self.rowIndex(row)], with: .automatic)
                }
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            StorageManager.shared.done(taskList: taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let taskVC = segue.destination as? TaskViewController else { return }
        
        let taskList = taskLists[indexPath.row]
        taskVC.taskList = taskList
    }
    
    // MARK: - IB Actions
    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        taskLists = sender.selectedSegmentIndex == 0
            ? taskLists.sorted(byKeyPath: "name")
            : taskLists.sorted(byKeyPath: "date")
        
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    private func createTempData() {
        DataManager.shared.createTempData {
            self.tableView.reloadData()
        }
    }
    
    private func setupUI() {
        title = "Task List"
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.tableFooterView = UIView()
        
        editButtonEnabled(taskLists.count)
    }
    
}

// MARK: - Ext. Show Alert
extension TaskListViewController {
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let title = taskList != nil ? "Edit List" : "New List"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Please set title for new task list")
        
        alert.action(with: taskList) { newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList: taskList, newValue: newValue)
                completion()
            } else {
                self.save(taskList: newValue)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(taskList: String) {
        let taskList = TaskList(value: [taskList])
        StorageManager.shared.save(taskList: taskList)
        
        if sortSegmentedControl.selectedSegmentIndex == 0 {
            guard let index = taskLists.index(of: taskList) else { return }
            tableView.insertRows(at: [rowIndex(index)], with: .automatic)
        } else {
            tableView.insertRows(at: [rowIndex(taskLists.count - 1)], with: .automatic)
        }
        
        editButtonEnabled(taskLists.count)
    }
    
}
