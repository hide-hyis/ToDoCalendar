//
//  SearchViewController.swift
//  ToDoCalendar
//
//  Created by 石井秀泰 on 2020/02/08.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import Firebase

protocol CatchProtocol {
    func catchData(key:[String: String])
}

class SearchViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate,  UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dateFromTextField: UITextField!
    @IBOutlet weak var dateToTextField: UITextField!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var categoryButton: UIButton!
    
    let screenHeight = Int(UIScreen.main.bounds.size.height)
    let screenWidth = Int(UIScreen.main.bounds.size.width)
    var resultHandler: (([String:String]) -> Void)?
    var priority = Int()
    var datePicker: UIDatePicker = UIDatePicker()
    var searchButton2  = UIButton()
    var delegate:CatchProtocol?
    var dateFromKey:Date?
    var dateToKey:Date?
    var isSearchResult = true                            //日付不整合バリデーションフラグ
    var categoryArray = [Category]()                     // ピッカー内に表示するカテゴリー配列
    var categoryIdArray = [String]()
    var categoryId: String = ""                              // 選択中のカテゴリーID
    var categoryPickerView = UIPickerView()             // カテゴリー表示用のピッカー
    var toolbar = UIToolbar()                           // カテゴリーピッカーのツールバー
    
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTextView.delegate = self
        titleTextField.delegate = self
        Layout.textViewOutLine(contentTextView)
        categoryButton.layer.borderWidth = 1
        categoryButton.layer.cornerRadius = 5
        contentTextView.layer.cornerRadius = 5
        
        contentTextView.text = "内容"
        contentTextView.textColor = .lightGray
        
        configureDatePicker()
        
        //iOS13以前用の擬似ナビバーを生成
        makeNavbar()
        
        // カテゴリーの取得
        fetchCategories()
        // カテゴリーピッカービューの生成
        configurePickerView()
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.textColor == UIColor.lightGray {
            contentTextView.text = nil
            contentTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text.isEmpty {
            contentTextView.text = "内容"
            contentTextView.textColor = UIColor.lightGray
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: EVENT ACTION
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
        var contentString = contentTextView.text!
        let priorityString = String(priority)
        let dateFromString = dateFromTextField.text!
        let dateToString = dateToTextField.text!
        let categoryId = self.categoryId
        if contentString == "内容"{
             contentString = ""
        }
        
        let inputDictionary:[String: String] = ["title": titleString,
                                              "content": contentString,
                                              "dateFrom": dateFromString,
                                              "dateTo": dateToString,
                                              "categoryId": categoryId,
                                              "priority": priorityString]
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
        
        //検索項目なしでバリデーション
        if  ( searchKeys.count == 0) {
            return
        } else if  (dateFromKey != nil && dateToKey != nil) {
            
            if isSearchResult == false {return}
        }
        
        delegate?.catchData(key: searchKeys)
        self.dismiss(animated: true)
    }
    
    @IBAction func showCategoryPicker(_ sender: Any) {
        print(categoryArray.count)
        for i in categoryArray {
            print("カテゴリ名: \(String(describing: i.name))")
        }
        if self.categoryPickerView.isHidden == false{
            self.categoryPickerView.isHidden = true
            self.toolbar.isHidden = true
        }else{
            self.categoryPickerView.isHidden = false
            self.toolbar.isHidden = false
        }
    }
    
    
    
    @objc func cancellCategoryPicker(){
        if self.categoryPickerView.isHidden == false{
            
            self.categoryPickerView.isHidden = true
            self.toolbar.isHidden = true
        }
    }
    
    @objc func handleCategory(){
        
        self.categoryPickerView.isHidden = true
        self.toolbar.isHidden = true
    }
    
    // MARK: UIPickerViewDelegate for Category
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.categoryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.text = self.categoryArray[row].name
        pickerLabel.font = UIFont.systemFont(ofSize: 22)
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCategory = self.categoryArray[row].name
        categoryButton.setTitle(selectedCategory, for: .normal)
        categoryId = self.categoryIdArray[row]
    }
    
    // MARK: Handlers
    //日付が不整合の場合
    func dateCheck() -> Bool {
        dateFromKey = DateUtils.dateFromString(string: dateFromTextField.text!, format: "yyyy年MM月dd日")
        dateToKey = DateUtils.dateFromString(string: dateToTextField.text!, format: "yyyy年MM月dd日")
        print("dateFromKey: \(dateFromKey!),  dateToKey: \(dateToKey!)")
        
        if ( dateFromKey!.compare(dateToKey!) == .orderedDescending){ //dateFromKeyがdateToKeyより後の日付の場合
    //      バリデーションを画面に反映
            dateFromTextField.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 0.5)
            dateFromTextField.textColor = UIColor.gray
            dateFromTextField.layer.cornerRadius = 10
            dateFromTextField.textAlignment = NSTextAlignment.center
            dateToTextField.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 0.5)
            dateToTextField.textColor = UIColor.gray
            dateToTextField.layer.cornerRadius = 10
            dateToTextField.textAlignment = NSTextAlignment.center
            isSearchResult = false
            return isSearchResult
        }
        //日付OK
        dateFromTextField.backgroundColor = UIColor.clear
        dateFromTextField.textColor = UIColor.black
        dateToTextField.backgroundColor = UIColor.clear
        dateToTextField.textColor = UIColor.black
        isSearchResult = true
        return isSearchResult
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
    
    func makeNavbar(){

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
    
    func configureDatePicker(){
        DateUtils.pickerConfig(datePicker, dateFromTextField)
        DateUtils.pickerConfig(datePicker, dateToTextField)
        // 決定バーの生成
        let toolbar1 = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let toolbar2 = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let dateFromDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateFromDone))
        toolbar1.setItems([spacelItem, dateFromDoneButton], animated: true)
        let dateToDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateToDone))
        toolbar2.setItems([spacelItem, dateToDoneButton], animated: true)
        
        dateFromTextField.inputView = datePicker
        dateFromTextField.inputAccessoryView = toolbar1
        dateToTextField.inputView = datePicker
        dateToTextField.inputAccessoryView = toolbar2
    }
    
    // UIDatePickerのDateFromDoneを押したら発火
    @objc func dateFromDone() {
        dateFromTextField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        dateFromTextField.text = "\(formatter.string(from: datePicker.date))"
        if ( dateFromTextField.text != "選択" && dateToTextField.text != "選択"){
            print("Date From -> dateFromTextField: \(dateFromTextField.text!),  dateToTextField: \(dateToTextField.text!)")
            self.dateCheck()
        }
    }
    
    // UIDatePickerのDateToを押したら発火
    @objc func dateToDone() {
        dateToTextField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        dateToTextField.text = "\(formatter.string(from: datePicker.date))"
        if ( dateFromTextField.text != "選択" && dateToTextField.text != "選択"){
            print("Date To -> dateFromTextField: \(dateFromTextField.text!),  dateToTextField: \(dateToTextField.text!)")
            self.dateCheck()
        }
    }
    
    func configurePickerView(){
        // ツールバーの生成
        let cancell = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancellCategoryPicker))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(handleCategory))
        toolbar.setItems([cancell, spacelItem, doneItem], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.frame = CGRect(x: 0, y: screenHeight-220-35, width: screenWidth, height: 35)
        toolbar.backgroundColor = .white
        view.addSubview(toolbar)
        toolbar.isHidden = true
        
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        let pickerWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        categoryPickerView.frame = CGRect(x: 0, y: screenHeight - 220, width: pickerWidth, height: 220)
        categoryPickerView.backgroundColor  = UIColor.rgb(red: 230, green: 230, blue: 230, alpha: 1)
        view.addSubview(categoryPickerView)
        categoryPickerView.isHidden = true
    }
    // MARK: API
    func fetchCategories(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        CATEGORIES_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
            let fetchCategoryId = snapshot.key
            
            let category = Category(dictionary: dictionary)
            self.categoryIdArray.append(fetchCategoryId)
            self.categoryArray.append(category)
            self.categoryButton.setTitle("カテゴリー", for: .normal)
            self.categoryPickerView.reloadAllComponents()
        }
    }
}
