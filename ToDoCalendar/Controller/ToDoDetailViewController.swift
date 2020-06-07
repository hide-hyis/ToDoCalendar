//
//  ToDoDetailViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/02/04.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import Photos


protocol DetailProtocol {
    func catchtable(editKeys: [String: String])
}

class ToDoDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    
    
    let screenHeight = Int(UIScreen.main.bounds.size.height)
    let screenWidth = Int(UIScreen.main.bounds.size.width)
    var priority = Int()
    var isDone = Bool()
    var datePicker: UIDatePicker = UIDatePicker()
    var delegate:DetailProtocol?
    var allY:CGFloat = 0.0
    var todo: FToDo?
    var selectedTodoImage: UIImage?
    var categoryArray = [Category]()
    var categoryIdArray = [String]()
    var categoryId: String?                              // 選択中のカテゴリーID
    var categoryPickerView = UIPickerView()             // カテゴリー表示用のピッカー
    var toolbar = UIToolbar()
    var initialImage: Bool?

        
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var isDoneSegment: UISegmentedControl!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var testConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryButton: UIButton!
    
    // MARK: View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.layer.borderWidth = 0.5
        titleTextField.layer.borderColor = UIColor.gray.cgColor
        titleTextField.delegate = self
        contentTextView.delegate = self
        
        let dateFromUnix = Date(timeIntervalSince1970: Double(todo!.scheduled))
        let dateString = DateUtils.stringFromDate(date: dateFromUnix, format: "yyyy年MM月dd日")
        priority = (todo?.priority)!
        
        //表示するToDoの取得
        configureToDo(date: dateString)
        
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.borderColor = UIColor.gray.cgColor
        contentTextView.layer.cornerRadius = 1.0
        
        configureDatePicker(date: dateString)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPicker))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
//        ToDo.isDoneDisplay(isDone, isDoneSegment)
        
        // カテゴリーの取得
        fetchCategories()
        //iOS13以前用の擬似ナビバーを生成
        makeNavbar()
        
        // カテゴリーピッカービューの生成
        configurePickerView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()

    }
    
    
    // MARK: EVENT ACTION
    //完了切替
    @IBAction func segmentAction(_ sender: Any) {
        
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            todo?.isDone = false
        case 1:
            todo?.isDone = true
        default:
            print("エラ-")
        }
    }
    
    //星1つタップ
    @IBAction func star1Action(_ sender: Any) {
        Layout.star1Button(star1, star2, star3)
        priority = 1
    }
    //星2つタップ
    @IBAction func star2Action(_ sender: Any) {
        Layout.star2Button(star1, star2, star3)
        priority = 2
    }
    //星3つタップ
    @IBAction func star3Action(_ sender: Any) {
        Layout.star3Button(star1, star2, star3)
        priority = 3
    }
    
    //編集機能
    @IBAction func editAction(_ sender: Any) {
        
        // 画像を保存する場合
        if titleTextField.text != "" && titleTextField.text!.count < 16
        && contentTextView.text!.count < 201 && priority != 0 && self.selectedTodoImage != nil{

            // image uploadData
            guard let todoImage = self.selectedTodoImage else {return}
            guard let uploadData = todoImage.jpegData(compressionQuality: 0.5) else {return}
            // update storage
            let filename = NSUUID().uuidString
            let storageRef = STORAGE_TODO_IMAGES_REF.child(filename)
            
            //古い画像をサーバーから削除
            Storage.storage().reference(forURL: todo!.imageURL).delete(completion: nil)
            
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                
                //エラーハンドル
                if let error = error{
                    print("画像のアップロードエラー", error.localizedDescription)
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    guard let todoImageUrl = url?.absoluteString else {return}
                    
                    self.inputValues(withImage: todoImageUrl)
                }
            }
        
        // 画像を保存しない場合
        } else if titleTextField.text != "" && titleTextField.text!.count < 16 && contentTextView.text!.count < 201 && priority != 0 && self.selectedTodoImage == nil{
            self.inputValues(withImage: "")
        }
        
    }
    
    //削除機能
    @IBAction func deleteAction(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title: "ToDoを削除しますか?", message: nil, preferredStyle:  UIAlertController.Style.alert)

        let deleteAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive, handler:{
               (action: UIAlertAction!) -> Void in
                self.deleteTodoFromServer()
                
            let keys = ["title": "タイトル", "content": "内容", "priority": "1", "scheduledAt": "予定日"] as [String : Any]
            self.delegate?.catchtable(editKeys: keys as! [String : String])
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
    
//    画面を下スワイプで画面遷移
    @IBAction func swipeDown(_ sender: Any) {
        if #available(iOS 13.0, *) {
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func toggleCategoryPicker(_ sender: Any) {
        if self.categoryPickerView.isHidden == false{
            self.categoryPickerView.isHidden = true
            self.toolbar.isHidden = true
        }else{
            print("Category: \(self.categoryArray.count)件")
            self.categoryPickerView.isHidden = false
            self.toolbar.isHidden = false
             titleTextField.resignFirstResponder()
        }
    }
    
    // ピッカーのキャンセルボタンタップ
    @objc func cancellCategoryPicker(){
        if self.categoryPickerView.isHidden == false{
            
            self.categoryPickerView.isHidden = true
            self.toolbar.isHidden = true
        }
    }
    
    // ピッカーの完了ボタンタップ
    @objc func handleCategory(){
        
        self.categoryPickerView.isHidden = true
        self.toolbar.isHidden = true
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
            let size = CGSize(width: 130, height: 130)
            selectedTodoImage = pickedImage
            self.imageView.image = selectedTodoImage!.resize(size: size)
            initialImage = false
            picker.dismiss(animated: true, completion: nil)
        }
    }
    // 画像選択ピッカーの表示
    @objc func showPicker(){
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
        // 変更前の画像かどうか
        if initialImage! {
            selectedTodoImage = self.imageView.image
        }
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
    // MARK: Handlers
    func inputValues(withImage: String){
        
        let dateString = dateField.text
        let updateTime = Date().timeIntervalSince1970
        
        let selectedDate = DateUtils.dateFromString(string: dateString!, format: "yyyy年MM月d日")
        let scheduleUnixString = String(selectedDate.timeIntervalSince1970).prefix(10)
        let scheduleInt = Int(scheduleUnixString)
        let editTitle:String = titleTextField.text!
        guard let todoId = todo?.todoId else {return}
        
        // 変更前の画像かどうか
        if initialImage! {
            selectedTodoImage = self.imageView.image
        }
        
        let values = ["title": editTitle,
                    "content": contentTextView.text,
                    "schedule": scheduleInt,
                    "priority": priority,
                    "isDone": todo?.isDone,
                    "imageURL": withImage,
                    "userId": todo?.userId,
                    "categoryId": categoryId,
                    "createdTime": todo?.createdTime,
                    "updatedTime": updateTime] as [String: Any]
        
        TODOS_REF.child(todoId).updateChildValues(values)
        editButton.isEnabled = false
        let keys = ["title": editTitle, "content": contentTextView.text, "priority": String(priority), "scheduledAt": dateString] as [String : Any]
        delegate?.catchtable(editKeys: keys as! [String : String])
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureToDo(date dateString: String){
        dateField.text = dateString
        contentTextView.text = todo?.content
        titleTextField.text = todo?.title
        
        // 優先度表示
        switch priority {
        case 1:
            Layout.star1Button(star1, star2, star3)
            todo?.priority = 1
        case 2:
            Layout.star2Button(star1, star2, star3)
            todo?.priority = 2
        case 3:
            Layout.star3Button(star1, star2, star3)
            todo?.priority = 3
        default:
            return
        }
        
        // 完了/未完了表示
        guard let isDone = todo?.isDone else {return}
        if isDone {
            isDoneSegment.selectedSegmentIndex = 1
        } else {
            isDoneSegment.selectedSegmentIndex = 0
        }
        
        // 画像表示
        if todo?.imageURL == ""{
            self.imageView.image = UIImage(named: "plus-icon")
            initialImage = false
        }else if let imageUrl = todo?.imageURL{
            self.imageView.loadImage(with: imageUrl)
            initialImage = true
//            let data: Data = (todo?.imageURL.data(using: String.Encoding.utf8))!
//            print(data)
//            let image: UIImage? = UIImage(data: data)
//            selectedTodoImage = image
//            selectedTodoImage = self.imageView.image
        }
        
        // カテゴリー表示
        if todo?.categoryId == "カテゴリー不明"{
            self.categoryButton.setTitle("カテゴリー不明", for: .normal)
        }else if todo?.categoryId == ""{
            self.categoryButton.setTitle("カテゴリー不明", for: .normal)
        }else{
            categoryId = todo?.categoryId
            fetchCategoryName(withCategoryId: categoryId!)
        }
    }
    
    // UIDatePickerのDoneを押したら発火
    @objc func dateDone() {
        dateField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        dateField.text = "\(formatter.string(from: datePicker.date))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // タイトル欄入力後バリデーションチェック
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        titleTextField.resignFirstResponder()
        contentTextView.resignFirstResponder()
    }
    
    //決定ボタンの無効/有効化
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        ToDo.textFieldAlert(titleTextField, editButton, 15)
        if titleTextField.text == "" || titleTextField.text!.count > 15{
            titleTextField.placeholder = "タイトルを入力してください"
            ToDo.invalidButton(editButton)
        }else {
            ToDo.validButton(editButton)
        }
    }
    
    //内容欄入力後バリデーションチェック
    func textViewDidChange(_ textView: UITextView) {
        
        ToDo.textViewdAlert(contentTextView, editButton, 200)
    }
    

    //擬似bナビバー
    func makeNavbar(){
        if #available(iOS 13.0, *) {
        } else {
            Layout.blankView(self) //navに白紙
            Layout.navBarTitle(self, "ToDo") //navBarTitle
//            戻るボタン
            let backButton  = UIButton()
            backButton.frame = CGRect(x: 20, y: 60, width: 20, height: 20)
            let backButtonImage = UIImage(named: "calendar-1")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            backButton.setImage(backButtonImage, for: .normal)
            backButton.setTitleColor(UIColor.blue, for: .normal)
            backButton.addTarget(self, action: #selector(ToDoDetailViewController.backAction), for: UIControl.Event.touchUpInside)
            self.view.addSubview(backButton)
            self.view.bringSubviewToFront(backButton)
//            削除ボタン
            let deleteButton  = UIButton()
            deleteButton.frame = CGRect(x: 330, y: 60, width: 20, height: 20)
            let deleteButtonImage = UIImage(named: "delete")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            deleteButton.setImage(deleteButtonImage, for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteAction), for: UIControl.Event.touchUpInside)
            self.view.addSubview(deleteButton)
            self.view.bringSubviewToFront(deleteButton)
            
            Layout.segmentLayout(isDoneSegment)
            
        }
    }
    
    
    func configureDatePicker(date dateString: String){
        DateUtils.pickerConfig(datePicker, dateField)
        let date = DateUtils.dateFromString(string: dateString, format: "yyyy年MM月d日")
        datePicker.date = date
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateDone))
        toolbar.setItems([spacelItem, doneItem], animated: true)

        // インプットビュー設定(紐づいているUITextfieldへ代入)
        dateField.inputView = datePicker
        dateField.inputAccessoryView = toolbar
    }
    
    func configurePickerView(){
        // ツールバーの生成
        let cancell = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancellCategoryPicker))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(handleCategory))
        toolbar.setItems([cancell, spacelItem, doneItem], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.frame = CGRect(x: 0, y: screenHeight-150-35, width: screenWidth, height: 35)
        toolbar.backgroundColor = .white
        view.addSubview(toolbar)
        toolbar.isHidden = true
        
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        let pickerWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        categoryPickerView.frame = CGRect(x: 0, y: screenHeight - 150, width: pickerWidth, height: 150)
        categoryPickerView.backgroundColor  = UIColor.rgb(red: 230, green: 230, blue: 230, alpha: 1)
        view.addSubview(categoryPickerView)
        categoryPickerView.isHidden = true
    }
    // MARK:　API
    // FirebaseにToDo削除を送信
    func deleteTodoFromServer(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        guard let todoId = self.todo?.todoId else {return}
        USER_TODOS_REF.child(currentUid).child(todoId).removeValue { (err, ref) in
            TODOS_REF.child(todoId).removeValue()
        }
    }
    
    func fetchCategories(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        CATEGORIES_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
            let categoryId = snapshot.key
            
            let category = Category(dictionary: dictionary)
            self.categoryIdArray.append(categoryId)
            self.categoryArray.append(category)
            self.categoryPickerView.reloadAllComponents()
        }
    }
    
    
    func fetchCategoryName(withCategoryId categoryId: String){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        CATEGORIES_REF.child(currentUid).child(categoryId).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
            
            let category = Category(dictionary: dictionary)
            self.categoryButton.setTitle(category.name, for: .normal)
            self.categoryPickerView.reloadAllComponents()
        }
    }
}
