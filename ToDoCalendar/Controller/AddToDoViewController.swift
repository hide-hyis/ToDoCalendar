//
//  AddToDoViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/01/29.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import RealmSwift

class AddToDoViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    
    @IBOutlet weak var star: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    var selectedDateString = String()
    
    var priority = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        contentTextField.layer.borderWidth = 1.0
        contentTextField.layer.borderColor = UIColor.gray.cgColor
        contentTextField.layer.cornerRadius = 1.0
        
        selectedDateLabel.text = selectedDateString
    }
    
    @IBAction func starButton(_ sender: Any) {
        ToDo.star1Button(star, star2, star3)
        priority = 1
    }
    @IBAction func star2Button(_ sender: Any) {
        ToDo.star2Button(star, star2, star3)
        priority = 2
    }
    @IBAction func star3Button(_ sender: Any) {
        ToDo.star3Button(star, star2, star3)
        priority = 3
        
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if titleTextField.text!.count > 0 {
//            let str = titleTextField.text!
//            let beggingLetter = str.prefix(3)
//            let overLetter = str[str.index(str.startIndex, offsetBy: 3)..<str.endIndex]
//            let word = String(overLetter)
//
////            titleTextField.text.backgroundColor = UIColor(red: 0.7, green: 0.2, blue: 0.3, alpha: 0.7)
////            print("over: \(overLetter)")
//
//            let text = NSMutableAttributedString(string: word)
//            let endNum = str.count
//            print("endNum: \(endNum)")
//            text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSMakeRange(0, 4))
//            titleTextField.attributedText = text
////            titleTextField.text = "\(str.prefix(15)) + \(overLetter)"
//        }
//    }
    // キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func saveAction(_ sender: Any) {
        
        if titleTextField.text! != "" && titleTextField.text!.count < 16
            && contentTextField.text!.count < 201 && priority != 0 {
                    let selectedDate = DateUtils.dateFromString(string: selectedDateString, format: "yyyy年MM月d日")
                    let todo = ToDo()
                    todo.title = titleTextField.text!
                    todo.content = contentTextField.text
                    todo.scheduledAt = selectedDate as Date
                    todo.priority = priority
                    todo.isDone = false
                     
                    let realm = try! Realm()
                    try! realm.write{
                        realm.add(todo)
                    }
        //            print("RealmファイルURL: \(Realm.Configuration.defaultConfiguration.fileURL!)")
                    self.navigationController?.popViewController(animated: true)
                } else{
                    print("項目を全て記入してください")
                    
                }
    }
    
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
}

