//
//  ToDoDetailViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/02/04.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var titleString = String()
    var contentString = String()
    var priority = Int()
    var selectedDateString = String()
    var isDone = Bool()
    var datePicker: UIDatePicker = UIDatePicker()
        
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var isDoneSegment: UISegmentedControl!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        contentTextView.delegate = self
        dateField.text = selectedDateString
        contentTextView.text = contentString
        titleTextField.text = titleString
        switch priority {
        case 1:
            ToDo.star1Button(star1, star2, star3)
            priority = 1
        case 2:
            ToDo.star2Button(star1, star2, star3)
            priority = 2
        case 3:
            ToDo.star3Button(star1, star2, star3)
            priority = 3
        default:
            return
        }
        
        DateUtils.pickerConfig(datePicker, dateField)

        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateDone))
        toolbar.setItems([spacelItem, doneItem], animated: true)

        // インプットビュー設定(紐づいているUITextfieldへ代入)
        dateField.inputView = datePicker
        dateField.inputAccessoryView = toolbar
        
        ToDo.isDoneDisplay(isDone, isDoneSegment)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
    }
    
    
    // UIDatePickerのDoneを押したら発火
    @objc func dateDone() {
        dateField.endEditing(true)
        // 日付のフォーマット
        let formatter = DateFormatter()
        //"yyyy年MM月dd日"を"yyyy/MM/dd"したりして出力の仕方を好きに変更できるよ
        formatter.dateFormat = "yyyy年MM月dd日"
        //(from: datePicker.date))を指定してあげることで,datePickerで指定した日付が表示される
        dateField.text = "\(formatter.string(from: datePicker.date))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //決定ボタンの無効/有効化
    func textFieldDidEndEditing(_ textField: UITextField) {
        if titleTextField.text == "" {
            titleTextField.placeholder = "タイトルを入力してください"
            ToDo.invalidButton(editButton)
        }else {
            ToDo.validButton(editButton)
        }
    }
    
    //完了切替
    @IBAction func segmentAction(_ sender: Any) {
        
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            isDone = false
        case 1:
            isDone = true
        default:
            print("エラ-")
        }
    }
    
    
    @IBAction func star1Action(_ sender: Any) {
        ToDo.star1Button(star1, star2, star3)
        priority = 1
    }
    @IBAction func star2Action(_ sender: Any) {
        ToDo.star2Button(star1, star2, star3)
        priority = 2
    }
    @IBAction func star3Action(_ sender: Any) {
        ToDo.star3Button(star1, star2, star3)
        priority = 3
    }
    
    //編集機能
    @IBAction func editAction(_ sender: Any) {
        let dateString = dateField.text
        let selectedDate = DateUtils.dateFromString(string: dateString!, format: "yyyy年MM月d日")
//        print("dateField: \(date)")
        let realm = try! Realm()
        let todo = realm.objects(ToDo.self).filter(" title == %@", titleTextField.text!).first
//        let editTitle:String = titleTextField.text!
//        print("編集タイトル: \(editTitle)")
        if titleTextField.text != "" {
                try! realm.write{
        //            todo!.title = editTitle
                    todo!.content = contentTextView.text
                    todo!.priority = priority
                    todo!.scheduledAt = selectedDate
                    todo!.isDone = isDone
                }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    //削除機能
    @IBAction func deleteAction(_ sender: Any) {
        
        let realm = try! Realm()
        let todo = realm.objects(ToDo.self).filter(" title == %@", titleTextField.text!).first
        
        let alert: UIAlertController = UIAlertController(title: "アラート表示", message: "削除してもいいですか？", preferredStyle:  UIAlertController.Style.alert)

        let deleteAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive, handler:{
               (action: UIAlertAction!) -> Void in
               try! realm.write{
                   realm.delete(todo!)
               }
            self.dismiss(animated: true, completion: nil)
           })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
               (action: UIAlertAction!) -> Void in
           })

           alert.addAction(cancelAction)
           alert.addAction(deleteAction)

        present(alert, animated: true, completion: nil)
    }
    

    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
