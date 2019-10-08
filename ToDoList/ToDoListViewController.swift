//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Raunak Sinha on 07/06/19.
//  Copyright © 2019 Raunak Sinha. All rights reserved.
//

import UIKit
import RealmSwift


protocol ToDoListDelegate: class {
    func update()
}



class ToDoListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    
    @IBAction func addTask(_ sender: Any) {
        performSegue(withIdentifier: "addTaskSegue", sender: nil)
    }
    
    @IBOutlet weak var addTaskTapped: UIBarButtonItem!
    
    
    @objc func edit(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing{
            addTaskTapped.isEnabled = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(edit(_:)))
        }else {
            addTaskTapped.isEnabled = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit(_:)))
        }
    }
    
    
    
    @IBOutlet weak var editTapped: UIBarButtonItem!
    
    //var toDoItems: [ToDoItems] = []
    
    var toDoItems: Results<Task>? {
        
        get {
            guard let realm = LocalDatabaseManager.realm else {
                return nil
            }
            return realm.objects(Task.self)
        }
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTask(_:)), name: NSNotification.Name.init("com.todolistapp.addtask"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setEditing(false, animated: false)
    }
    
    
    
    @objc func addNewTask(_ notification: NSNotification) {
        
        
        
        /*var toDoItem: ToDoItems
        if let task = notification.object as? ToDoItems{
            toDoItem = task
        }else {
            return
        }
        toDoItems.append(toDoItem)
        
        
        toDoItems.sort(by: { $0.completionDate < $1.completionDate })*/
        tableView.reloadData()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //self.toDoItems.remove(at: indexPath.row)
            guard let realm = LocalDatabaseManager.realm else {
                return
            }
            do {
                try realm.write {
                    realm.delete(self.toDoItems![indexPath.row])
                }
            }
            catch let error as NSError {
                print(error.localizedDescription)
                return
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = toDoItems![indexPath.row]
        let toDOtuple = (indexPath.row,selectedItem)
        performSegue(withIdentifier: "showDetailSegue", sender: toDOtuple)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let toDo = toDoItems![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItem")!
        cell.textLabel?.text = toDo.title
        cell.detailTextLabel?.text = toDo.isCompleted ? "Completed" : "Incomplete"
        return cell
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegue"{
            guard let destinationVC = segue.destination as? ToDoDetailsViewController else {return}
            guard let toDoTuple = sender as? (Int, Task) else {return}
            destinationVC.toDoItem = toDoTuple.1
            destinationVC.toDoIndex = toDoTuple.0
            destinationVC.delegate = self
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  NSNotification.Name.init("com.todolistapp.addtask"), object: nil)
    }

}





extension ToDoListViewController:ToDoListDelegate {
    func update() {
        //toDoItems[index] = task
        tableView.reloadData()
    
    }
    
}
