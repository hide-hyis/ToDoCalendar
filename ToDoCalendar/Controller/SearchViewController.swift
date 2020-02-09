//
//  SearchViewController.swift
//  ToDoCalendar
//
//  Created by 石井秀泰 on 2020/02/08.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit

protocol CatchProtocol {
    func catchData(key:[String: String])
}

class SearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dateFromTextField: UITextField!
    @IBOutlet weak var dateToTextField: UITextField!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    var resultHandler: (([String:String]) -> Void)?
    var priority = Int()
    var datePicker: UIDatePicker = UIDatePicker()
    var delegate:CatchProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        Layout.textViewOutLine(contentTextView)
        
        DateUtils.pickerConfig(datePicker, dateFromTextField)
        DateUtils.pickerConfig(datePicker, dateToTextField)
        
        // 決定バーの生成
        let toolbar1 = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let toolbar2 = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneItem1 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateDone1))
        toolbar1.setItems([spacelItem, doneItem1], animated: true)
        let doneItem2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateDone2))
        toolbar2.setItems([spacelItem, doneItem2], animated: true)
        
        dateFromTextField.inputView = datePicker
        dateFromTextField.inputAccessoryView = toolbar1
        dateToTextField.inputView = datePicker
        dateToTextField.inputAccessoryView = toolbar2
        
    }
    
    // UIDatePickerのDoneを押したら発火
    @objc func dateDone1() {
        dateFromTextField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        dateFromTextField.text = "\(formatter.string(from: datePicker.date))"
        print("dateDone1")
    }
    @objc func dateDone2() {
        dateToTextField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        dateToTextField.text = "\(formatter.string(from: datePicker.date))"
        print("dateDone2")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func star1Action(_ sender: Any) {
        Layout.star1Button(star1, star2, star3)
        priority = 1
    }
    @IBAction func star2Action(_ sender: Any) {
        Layout.star2Button(star1, star2, star3)
        priority = 2
    }
    @IBAction func star3Action(_ sender: Any) {
        Layout.star3Button(star1, star2, star3)
        priority = 3
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
        let titleString = titleTextField.text!
        let contentString = contentTextView.text!
        let priorityString = String(priority)
        let dateFromString = dateFromTextField.text!
        let dateToString = dateToTextField.text!
        let inputDictionary:[String: String] = ["title": titleString,
              "content": contentString,"dateFrom": dateFromString,
              "dateTo": dateToString, "priority": priorityString]
        var searchKeys = [String: String]()
        print("辞書の中身確認: \(inputDictionary)")
        for (key, value) in inputDictionary {
            if value != "" && value != "0" && value != "選択" {
                searchKeys.updateValue(value, forKey: key)
            }
        }
        print(("searchKeys: \(searchKeys)"))
        delegate?.catchData(key: searchKeys)
        self.dismiss(animated: true)
    }
    
}
