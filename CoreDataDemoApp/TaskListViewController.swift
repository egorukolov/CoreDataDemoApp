//
//  TaskListViewController.swift
//  CoreDataDemoApp
//
//  Created by Egor Ukolov on 22.07.2024.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let cellID = "cell"
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor : UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor : UIColor.white]
        navBarAppearance.backgroundColor = UIColor(red: 21/255,
                                                   green: 101/255,
                                                   blue: 192/255,
                                                   alpha: 194/255)
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addTask))
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addTask() {
        // let newTaskVC = NewTaskViewController()
       // newTaskVC.modalPresentationStyle = .fullScreen
       // present(newTaskVC, animated: true)
        
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func showAlert(with title: String, and message: String, taskToEdit: Task? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
      
            alert.addTextField { textField in
                textField.text = taskToEdit?.name
                textField.placeholder = "Task Name"
            }
        
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            if let taskToEdit = taskToEdit {
                self.delete(taskToEdit)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        
        if taskToEdit != nil {
            alert.addAction(deleteAction)
        }
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - Core Data

extension TaskListViewController {
    
    private func save(_ taskName: String) {
        guard let entityDescription = NSEntityDescription
            .entity(forEntityName: "Task", in: viewContext) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Task else { return }
        task.name = taskName
        tasks.append(task)
       
        let indexPath = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        do {
            try viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func delete(_ task: Task) {
        viewContext.delete(task)
        
        do {
            try viewContext.save()
            if let index = tasks.firstIndex(of: task) {
                tasks.remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
      
        do {
            tasks = try viewContext.fetch(fetchRequest)
        } catch let error{
           print(error)
        }
    }
    
}


// MARK: - Table view data source

extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        showAlert(with: "Edit Task", and: "Would you like to delete this task?", taskToEdit: task)
    }
    
}
