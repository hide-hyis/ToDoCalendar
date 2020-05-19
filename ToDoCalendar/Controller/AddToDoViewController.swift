//
//  AddToDoViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/01/29.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class AddToDoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    
    @IBOutlet weak var star: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var selectedDateString = String()
    
    var priority = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        contentTextField.delegate = self
        Layout.textViewOutLine(contentTextField)
        
        selectedDateLabel.text = selectedDateString

        //iOS13以前でもナビバーを表示
        if #available(iOS 13.0, *) {
        } else {
            let searchBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar-1")!, style: .plain, target: self, action:     #selector(backAction))
            navigationItem.leftBarButtonItem = searchBarButtonItem
        }
    }
    
    @IBAction func starButton(_ sender: Any) {
        Layout.star1Button(star, star2, star3)
        priority = 1
    }
    @IBAction func star2Button(_ sender: Any) {
        Layout.star2Button(star, star2, star3)
        priority = 2
    }
    @IBAction func star3Button(_ sender: Any) {
        Layout.star3Button(star, star2, star3)
        priority = 3
        
    }
    
//入力値制限アラート
    func textFieldDidEndEditing(_ textField: UITextField) {
        ToDo.textFieldAlert(titleTextField, addButton, 15)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        ToDo.textViewdAlert(contentTextField, addButton, 200)
    }
    
    // キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func saveAction(_ sender: Any) {
//        let currentId = Auth.auth().currentUser?.uid
        let currentId = "user1"
        if titleTextField.text! != "" && titleTextField.text!.count < 16
        && contentTextField.text!.count < 201 && priority != 0 {
                let selectedDate = DateUtils.dateFromString(string: selectedDateString, format: "yyyy年MM月dd日")
            /*
                let todo = ToDo()
                todo.title = titleTextField.text!
                todo.content = contentTextField.text
                todo.scheduledAt = selectedDate as Date
                todo.priority = priority
                todo.isDone = false
                 
                try! realm.write{
                    realm.add(todo)
                }
            */
                let scheduleUnix = selectedDate.timeIntervalSince1970
                let scheduleUnixString = String(selectedDate.timeIntervalSince1970).prefix(10)
                let scheduleString = String(scheduleUnixString)
                let createdTimeUnix = Date().timeIntervalSince1970
                
                let values = ["title": titleTextField.text!,
                            "content": contentTextField.text!,
                            "schedule": scheduleUnix,
                            "priority": priority,
                            "isDone": false,
                            "imageURL": "",
                            "userId": "user1",
                            "createdTime": createdTimeUnix,
                            "updatedTime": createdTimeUnix] as [String: Any]
            
                let todoId = TODO_REF.childByAutoId()
                guard let todoIdKey = todoId.key else {return}
                todoId.updateChildValues(values)
                
                USER_TODOS_REF.child(currentId).updateChildValues([todoIdKey: 1])
                
                CALENDAR_TODOS_REF.child(currentId).child(scheduleString).updateChildValues([todoIdKey: 1])
                self.navigationController?.popViewController(animated: true)
        } else{
            print("項目を全て記入してください")
            
        }
    }
    
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


