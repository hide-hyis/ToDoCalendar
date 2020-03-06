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
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var resultHandler: (([String:String]) -> Void)?
    var priority = Int()
    var datePicker: UIDatePicker = UIDatePicker()
    var searchButton2  = UIButton()
    var delegate:CatchProtocol?
    var dateFromKey:Date?
    var dateToKey:Date?

    
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
        
        if #available(iOS 13.0, *) {
        } else {
            Layout.blankView(self) //navに白紙
            Layout.navBarTitle(self, "検索") //navBarTitle
    //       戻るボタン
            let backButton  = UIButton()
            backButton.frame = CGRect(x: 20, y: 60, width: 20, height: 20)
            let backButtonImage = UIImage(named: "list")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            backButton.setImage(backButtonImage, for: .normal)
            backButton.addTarget(self, action: #selector(backAction), for: UIControl.Event.touchUpInside)
            self.view.addSubview(backButton)
            self.view.bringSubviewToFront(backButton)
    //        検索ボタン
            searchButton2.frame = CGRect(x: 330, y: 60, width: 20, height: 20)
            let searchButtonImage = UIImage(named: "search")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            searchButton2.setImage(searchButtonImage, for: .normal)
            searchButton2.addTarget(self, action: #selector(searchAction), for: UIControl.Event.touchUpInside)
            self.view.addSubview(searchButton2)
            self.view.bringSubviewToFront(searchButton2)
        }
        
    }
    
    // UIDatePickerのDoneを押したら発火
    @objc func dateDone1() {
        dateFromTextField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        dateFromTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    @objc func dateDone2() {
        dateToTextField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        dateToTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
   //入力値制限アラート
    func textFieldDidEndEditing(_ textField: UITextField) {
        if titleTextField.text!.count > 15 {
            let attrText = NSMutableAttributedString(string: titleTextField.text!)
            attrText.addAttributes([
                .foregroundColor: UIColor.gray,
                .backgroundColor: UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 0.5)
                ], range: NSMakeRange(15, titleTextField.text!.count - 15)
            )
            titleTextField.attributedText = attrText
        }
    }
    
//    優先度の星をタップしたアクション
    @IBAction func star1Action(_ sender: Any) {
        if priority != 1 {
            Layout.star1Button(star1, star2, star3)
            priority = 1
        } else {
            Layout.starZero(star1, star2, star3)
            priority = 0
        }
    }
    @IBAction func star2Action(_ sender: Any) {
        if priority != 2 {
            Layout.star2Button(star1, star2, star3)
            priority = 2
        } else {
            Layout.starZero(star1, star2, star3)
            priority = 0
        }
    }
    @IBAction func star3Action(_ sender: Any) {
        if priority != 3 {
            Layout.star3Button(star1, star2, star3)
            priority = 3
        } else {
            Layout.starZero(star1, star2, star3)
            priority = 0
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func swipeDown(_ sender: Any) {
        if #available(iOS 13.0, *) {
           } else {
               self.dismiss(animated: true, completion: nil)
           }
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
        
        //空欄項目以外を配列searchKeysに投入
        for (key, value) in inputDictionary {
            if value != "" && value != "0" && value != "選択" {
                searchKeys.updateValue(value, forKey: key)
                
            }
        }
        //日付を日付型に変換
        if searchKeys["dateFrom"] != nil {dateFromKey = DateUtils.dateFromString(string: searchKeys["dateFrom"]!, format: "yyyy年MM月dd日")}
        if searchKeys["dateTo"] != nil {dateToKey = DateUtils.dateFromString(string: searchKeys["dateTo"]!, format: "yyyy年MM月dd日")}
        
        //検索項目なしor日付の不整合でバリデーション
        if  ( searchKeys.count == 0) {
            return
        } else if  (dateFromKey != nil && dateToKey != nil) {
            if ( dateFromKey!.compare(dateToKey!) == .orderedDescending){ //dateFromKeyがdateToKeyより後の日付の場合
                return
            }
        }
        
        delegate?.catchData(key: searchKeys)
        self.dismiss(animated: true)
    }
    
}
