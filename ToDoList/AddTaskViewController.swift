//
//  AddTaskViewController.swift
//  ToDoList
//
//  Created by Raunak Sinha on 07/06/19.
//  Copyright © 2019 Raunak Sinha. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBOutlet weak var taskDetailsTextView: UITextView!
    
    @IBOutlet weak var taskCompletionDatePicker: UIDatePicker!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate: ToDoListDelegate?
    
    
    lazy var touchView: UIView = {
        
        let _touchView = UIView()
        
        _touchView.backgroundColor = UIColor(hue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 0)
        
        let touchViewTapped = UITapGestureRecognizer(target: self
            , action: #selector(doneButtonTapped))
        _touchView.addGestureRecognizer(touchViewTapped)
        _touchView.isUserInteractionEnabled = true
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        return _touchView
    }()
    
    let toolbarDone = UIToolbar.init()
    var activeTextField: UITextField?
    var activeTextView: UITextView?
    var keyboardNotification: NSNotification?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationItem = UINavigationItem(title: "Add Task")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTouch))
        navigationBar.items = [navigationItem]
        taskDetailsTextView.layer.borderColor = UIColor.lightGray.cgColor
        taskDetailsTextView.layer.borderWidth = CGFloat(1)
        taskDetailsTextView.layer.cornerRadius = CGFloat(3)
        
        
        toolbarDone.sizeToFit()
        toolbarDone.barTintColor = UIColor.red
        toolbarDone.isTranslucent = false
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let barbtnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        barbtnDone.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        toolbarDone.items = [flexSpace,barbtnDone,flexSpace]
        taskNameTextField.inputAccessoryView = toolbarDone
        taskDetailsTextView.inputAccessoryView = toolbarDone
        
        taskNameTextField.delegate = self
        taskDetailsTextView.delegate = self
        // Do any additional setup after loading the view.
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForTheKeybordNotifivation()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterForTheKeyboardNotification()
    }
    
    func registerForTheKeybordNotifivation () {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterForTheKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWasShown(notification: NSNotification){
        view.addSubview(touchView)
        self.keyboardNotification = notification
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contenInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height+toolbarDone.frame.size.height+10.0), right: 0.0)
        
        self.scrollView.contentInset = contenInsets
        self.scrollView.scrollIndicatorInsets = contenInsets
        
        var arect: CGRect = UIScreen.main.bounds
        arect.size.height -= keyboardSize!.height
        
        if activeTextField != nil{
            if(!arect.contains(activeTextField!.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeTextField!.frame, animated: true)
            }
        }else if activeTextView != nil {
            let textViewPiont: CGPoint = CGPoint(x: activeTextView!.frame.origin.x, y: activeTextView!.frame.size.height)
            
            if(arect.contains(textViewPiont)) {
                self.scrollView.scrollRectToVisible(activeTextView!.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWasHidden(notification: NSNotification){
        touchView.removeFromSuperview()
        let caontentInsets: UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = caontentInsets
        self.scrollView.scrollIndicatorInsets = caontentInsets
        self.view.endEditing(true)
    }
    
    
    
    @objc func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc func cancelButtonDidTouch(){
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTaskDidTouch(_ sender: Any) {
        
        guard let taskName = taskNameTextField.text, !taskName.isEmpty else{
            displayAlert(title: "Oops!", message: "Please enter a valid name")
            return
        }
        guard let taskDetails = taskDetailsTextView.text, !taskDetails.isEmpty else {
            displayAlert(title: "Oops!", message: "Please enter a valid detail")
            return
        }
        let completionDate = taskCompletionDatePicker.date
        if completionDate < Date() {
            displayAlert(title: "Oops!", message: "Please enter a valid date")
            return
        }
        
        guard let realm = LocalDatabaseManager.realm else {
            displayAlert(title: "Error", message: "A new task cannot be created")
            return
        }
        
        let nextTaskId = (realm.objects(Task.self).max(ofProperty: "id") as Int? ?? 0) + 1
        let newTask = Task()
        
        newTask.id = nextTaskId
        newTask.title = taskName
        newTask.details = taskDetails
        newTask.completionDate = completionDate as NSDate
        newTask.isCompleted = false
        
        do {
            try realm.write {
                realm.add(newTask)
            }
        }catch let error as NSError {
            print(error.localizedDescription)
            displayAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        //let toDoItem = ToDoItems(title: taskName, details: taskDetails, completionDate: completionDate)
        
        NotificationCenter.default.post(name: NSNotification.Name.init("com.todolistapp.addtask"), object: nil, userInfo: nil)
        
        dismiss(animated: true, completion: nil)
        
    }
    
        func displayAlert(title : String,message : String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}

extension AddTaskViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
extension AddTaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        activeTextView = textView
        guard let notification = self.keyboardNotification else {return}
        
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contenInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height+toolbarDone.frame.size.height+10.0), right: 0.0)
        
        self.scrollView.contentInset = contenInsets
        self.scrollView.scrollIndicatorInsets = contenInsets
        
        var arect: CGRect = UIScreen.main.bounds
        arect.size.height -= keyboardSize!.height
        
        let textViewPiont: CGPoint = CGPoint(x: textView.frame.origin.x, y: textView.frame.size.height)
        
        if(arect.contains(textViewPiont)) {
            self.scrollView.scrollRectToVisible(textView.frame, animated: true)
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
    
}
