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

class ToDoDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    var priority = Int()
    var isDone = Bool()
    var datePicker: UIDatePicker = UIDatePicker()
    var delegate:DetailProtocol?
    var allY:CGFloat = 0.0
    var todo: FToDo?
    var selectedTodoImage: UIImage?
        
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
    @IBOutlet weak var categoryLabel: UILabel!
    
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
        
        //iOS13以前用の擬似ナビバーを生成
        makeNavbar()
        
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
            selectedTodoImage = pickedImage.resize(size: size)
            self.imageView.image = selectedTodoImage
            
            if let imageUrl = info[UIImagePickerController.InfoKey.referenceURL] as? NSURL{

                print("DEBUG imageUrl: \(imageUrl)")
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
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

           alert.addAction(cancelAction)
           alert.addAction(cameraAction)
           alert.addAction(AlbumAction)
           alert.addAction(deleteAction)

        present(alert, animated: true, completion: nil)
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
        
        let values = ["title": editTitle,
        "content": contentTextView.text,
        "schedule": scheduleInt,
        "priority": priority,
        "isDone": todo?.isDone,
        "imageURL": withImage,
        "userId": todo?.userId,
        "createdTime": todo?.createdTime,
        "updatedTime": updateTime] as [String: Any]
        
        TODOS_REF.child(todoId).updateChildValues(values)
        let keys = ["title": editTitle, "content": contentTextView.text, "priority": String(priority), "scheduledAt": dateString] as [String : Any]
        delegate?.catchtable(editKeys: keys as! [String : String])
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureToDo(date dateString: String){
        dateField.text = dateString
        contentTextView.text = todo?.content
        titleTextField.text = todo?.title
        
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
        
        guard let isDone = todo?.isDone else {return}
        if isDone {
            isDoneSegment.selectedSegmentIndex = 1
        } else {
            isDoneSegment.selectedSegmentIndex = 0
        }
        
        if let imageUrl = todo?.imageURL{
            print("DEBUG imageUrl: \(imageUrl)")
            self.imageView.loadImage(with: imageUrl)
        }else{
            self.imageView.image = UIImage(named: "plus-icon")
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
    
    // MARK:　API
    // FirebaseにToDo削除を送信
    func deleteTodoFromServer(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        guard let todoId = self.todo?.todoId else {return}
        USER_TODOS_REF.child(currentUid).child(todoId).removeValue { (err, ref) in
            TODOS_REF.child(todoId).removeValue()
        }
    }
}
