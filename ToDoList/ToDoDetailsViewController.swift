//
//  ToDoDetailsViewController.swift
//  ToDoList
//
//  Created by Raunak Sinha on 07/06/19.
//  Copyright © 2019 Raunak Sinha. All rights reserved.
//

import UIKit

class ToDoDetailsViewController: UIViewController {
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    
    @IBOutlet weak var taskDetailsTextView: UITextView!
    
    @IBOutlet weak var taskCompletionButton: UIButton!
    
    @IBOutlet weak var taskCompletionDate: UILabel!
    
    var toDoItem: Task!
    
    
    var toDoIndex: Int!
    
    weak var delegate: ToDoListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitleLabel.text = toDoItem.title
        taskDetailsTextView.text = toDoItem.details
        if toDoItem.isCompleted{
            disableButton()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy hh:mm"
        let taskDate = formatter.string(from: toDoItem.completionDate as Date)
        taskCompletionDate.text = taskDate
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
    }
    
    @objc func edit(_ sender: Any){
        if taskDetailsTextView.isEditable {
            taskDetailsTextView.isEditable = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit(_:)))
        }else {
            taskDetailsTextView.isEditable = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(edit(_:)))
        }
        
    }
    
    func disableButton(){
        taskCompletionButton.backgroundColor = UIColor.gray
        taskCompletionButton.isEnabled = true
    }
    
    @IBAction func taskDidComplete(_ sender: Any) {
        //toDoItem.isCompleted = true
        guard let realm = LocalDatabaseManager.realm else {
            return
        }
        do {
            try realm.write {
                toDoItem.isCompleted = true
            }
        }catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        
        disableButton()
        delegate?.update()
    }
    
}
