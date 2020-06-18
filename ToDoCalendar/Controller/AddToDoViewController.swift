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
import Photos

class AddToDoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!    // todoコンテンツ
    @IBOutlet weak var categoryButton: UIButton!        // カテゴリーピッカー用ボタン
    
    @IBOutlet weak var star: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var addButton: UIButton!             // 追加決定ボタン
    @IBOutlet weak var imageView: UIImageView!          // todo内画像
    var activityIndicatorView = UIActivityIndicatorView()
    
    let screenHeight = Int(UIScreen.main.bounds.size.height)
    let screenWidth = Int(UIScreen.main.bounds.size.width)
    var selectedDateString = String()
    var selectedTodoImage: UIImage?                      // 表示中の画像
    var priority = 1
    var categoryArray = [Category]()                     // ピッカー内に表示するカテゴリー配列
    var categoryIdArray = [String]()
    var categoryId: String?                              // 選択中のカテゴリーID
    var categoryPickerView = UIPickerView()             // カテゴリー表示用のピッカー
    var toolbar = UIToolbar()                           // カテゴリーピッカーのツールバー
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        contentTextField.delegate = self
        Layout.textViewOutLine(contentTextField)
        
        selectedDateLabel.text = selectedDateString
        addButton.layer.cornerRadius = 5
        titleTextField.layer.cornerRadius = 5
        contentTextField.layer.cornerRadius = 5
        categoryButton.layer.cornerRadius = 5
        contentTextField.text = "内容"
        contentTextField.textColor = .lightGray
        addButton.isEnabled = false
        addButton.setTitleColor(.lightGray, for: .normal)
        
        // カテゴリーの取得
        fetchCategories()
        imageView.layer.cornerRadius = 10
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        activityIndicatorView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: (UIScreen.main.bounds.height/2)+50 )
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .black
        view.addSubview(activityIndicatorView)
        
        //iOS13以前用の擬似ナビバーを生成
        makeNavbar()
        
        // カテゴリーピッカービューの生成
        configurePickerView()
        
    }
    
    
    // MARK: EVENT ACTION
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
    
    
    @IBAction func saveAction(_ sender: Any) {
        guard let currentId = Auth.auth().currentUser?.uid else {return}
        
        // 記入内容のバリデーション
        if titleTextField.text! != "" && titleTextField.text!.count < 16
        && contentTextField.text!.count < 201 && priority != 0 && self.selectedTodoImage != nil{
            activityIndicatorView.startAnimating()

            DispatchQueue.global(qos: .default).async {
                // 非同期処理などを実行（今回は５秒間待つだけ）
                Thread.sleep(forTimeInterval: 5)

                // image uploadData
                guard let todoImage = self.selectedTodoImage else {return}
                guard let uploadData = todoImage.jpegData(compressionQuality: 0.5) else {return}
                // update storage
                let filename = NSUUID().uuidString
                let storageRef = STORAGE_TODO_IMAGES_REF.child(filename)
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                
                    //エラーハンドル
                    if let error = error{
                        print("画像のアップロードエラー", error.localizedDescription)
                        return
                    }
                        
                    storageRef.downloadURL { (url, error) in
                        guard let todoImageUrl = url?.absoluteString else {return}
                        
                        // DBへ情報の送信(画像を保存する場合)
                        self.inputValues(uid: currentId, withImage: todoImageUrl)
                    }
                }
                // 非同期処理などが終了したらメインスレッドでアニメーション終了
                DispatchQueue.main.async {
                    // アニメーション終了
                    self.activityIndicatorView.stopAnimating()
                }
            }
        }else if titleTextField.text! != "" && titleTextField.text!.count < 16
        && contentTextField.text!.count < 201 && priority != 0{

            // DBへ情報の送信(画像を保存しない場合)
           inputValues(uid: currentId, withImage: "")
        }else{
            print("項目を全て記入してください")
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showCategoryPicker(_ sender: Any) {
        
        if self.categoryPickerView.isHidden == false{
            self.categoryPickerView.isHidden = true
            self.toolbar.isHidden = true
        }else{
            if titleTextField.isEditing{
                titleTextField.endEditing(true)
            }
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
    
    
    // MARK: UIImagePickerControllerDelegate
    // アルバムの起動
    func handleLibrary(){
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        
        //ライブラリが利用可能か
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            //変数化
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            present(cameraPicker, animated: true, completion: nil)
            
        }else {
            print("エラー")
        }
    }
    // カメラの起動
    func handleCamera(){
        
        let sourceType = UIImagePickerController.SourceType.camera
        
        //カメラが利用可能か
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //変数化
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            self.present(cameraPicker, animated: true, completion: nil)
            
        }else {
            print("エラー")
        }
    }
    
    //撮影が完了した時に発火/アルバムから画像が選択された時に発火
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         
        if let pickedImage = info[.editedImage] as? UIImage{
            var size: CGSize!
            if screenHeight <= 736 {
                size = CGSize(width: 150, height: 150)
            }else{
                size = CGSize(width: 180, height: 180)
            }
            selectedTodoImage = pickedImage
            self.imageView.image = selectedTodoImage!.resize(size: size)
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: UIPickerViewDelegate for Category
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categoryArray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
    
    // MARK: UITextFieldDelegate
//入力値制限アラート
    func textFieldDidEndEditing(_ textField: UITextField) {
        ToDo.textFieldAlert(titleTextField, addButton, 15)
        if textField.text == ""{
            addButton.isEnabled = false
            addButton.setTitleColor(.lightGray, for: .normal)
        }else{
            addButton.isEnabled = true
            addButton.setTitleColor(.white, for: .normal)
        }
    }
    
    // キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !categoryPickerView.isHidden{
            toolbar.isHidden = true
            categoryPickerView.isHidden = true
        }
        self.view.endEditing(true)
    }
    
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        ToDo.textViewdAlert(contentTextField, addButton, 200)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !categoryPickerView.isHidden{
            toolbar.isHidden = true
            categoryPickerView.isHidden = true
        }
        if contentTextField.textColor == UIColor.lightGray {
            contentTextField.text = nil
            contentTextField.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextField.text.isEmpty {
            contentTextField.text = "内容"
            contentTextField.textColor = UIColor.lightGray
        }
    }
    // MARK: Handlers
    // 写真選択ピッカーの表示
    func showPicker(){
        let alert: UIAlertController = UIAlertController(title: "画像を選択してください", message: nil, preferredStyle:  UIAlertController.Style.actionSheet)

        let deleteAction: UIAlertAction = UIAlertAction(title: "取り消し", style: UIAlertAction.Style.destructive, handler:{
               (action: UIAlertAction!) -> Void in
            self.imageView.image = UIImage(named: "plus-icon")
            self.selectedTodoImage = nil
           })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
               (action: UIAlertAction!) -> Void in
           })
        
        let cameraAction: UIAlertAction = UIAlertAction(title: "カメラで撮影する", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.handleCamera()
        })
        
        let AlbumAction: UIAlertAction = UIAlertAction(title: "ライブラリから選択する", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.handleLibrary()
        })
        let showImageAction: UIAlertAction = UIAlertAction(title: "選択画像の表示", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.showImage()
        })

           alert.addAction(cancelAction)
           alert.addAction(cameraAction)
           alert.addAction(AlbumAction)
           alert.addAction(deleteAction)
        if selectedTodoImage != nil{ alert.addAction(showImageAction) }

        present(alert, animated: true, completion: nil)
    }
    
    func showImage(){
        let showImageViewVC = ShowImageViewController()
        showImageViewVC.selectedImage = selectedTodoImage!
        present(showImageViewVC, animated: true, completion: nil)
    }
    func inputValues(uid currentId: String, withImage: String){
        let selectedDate = DateUtils.dateFromString(string: selectedDateString, format: "yyyy年MM月dd日")
                   
                       let scheduleUnix = selectedDate.timeIntervalSince1970
                       let scheduleUnixString = String(selectedDate.timeIntervalSince1970).prefix(10)
                       let scheduleString = String(scheduleUnixString)
                       let createdTimeUnix = Date().timeIntervalSince1970
                       var content: String!
                       if contentTextField.text != "内容"{
                            content = contentTextField.text
                       }else{
                            content = ""
                       }
        
                        if categoryId == nil{ categoryId = ""}
                       let values = ["title": titleTextField.text!,
                                   "content": content,
                                   "schedule": scheduleUnix,
                                   "priority": priority,
                                   "isDone": false,
                                   "imageURL": withImage,
                                   "userId": currentId,
                                   "categoryId": categoryId,
                                   "createdTime": createdTimeUnix,
                                   "updatedTime": createdTimeUnix] as [String: Any]
                   
                       let todoId = TODOS_REF.childByAutoId()
                       guard let todoIdKey = todoId.key else {return}
                       todoId.updateChildValues(values)
                       
                       USER_TODOS_REF.child(currentId).updateChildValues([todoIdKey: 1])
                       
                       CALENDAR_TODOS_REF.child(currentId).child(scheduleString).updateChildValues([todoIdKey: 1])
                   
                       self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func imageTapped(){
        showPicker()
    }
    //iOS13以前でもナビバーを表示
    func makeNavbar(){
        if #available(iOS 13.0, *) {
        } else {
            let searchBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar-1")!, style: .plain, target: self, action:     #selector(backAction))
            navigationItem.leftBarButtonItem = searchBarButtonItem
        }
    }
    
    func configurePickerView(){
        // ツールバーの生成
        let pickerWidth = Int(UIScreen.main.bounds.size.width)
        let pickerHeight: Int = 200
        let cancell = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancellCategoryPicker))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(handleCategory))
        toolbar.setItems([cancell, spacelItem, doneItem], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.frame = CGRect(x: 0, y: screenHeight-pickerHeight-35, width: screenWidth, height: 35)
        toolbar.backgroundColor = .white
        view.addSubview(toolbar)
        toolbar.isHidden = true
        
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        categoryPickerView.frame = CGRect(x: 0, y: screenHeight - pickerHeight, width: pickerWidth, height: pickerHeight)
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
            self.categoryButton.setTitle("カテゴリー選択", for: .normal)
            self.categoryPickerView.reloadAllComponents()
        }
    }
}


