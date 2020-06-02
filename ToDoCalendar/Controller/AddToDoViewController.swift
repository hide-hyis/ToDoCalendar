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

class AddToDoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var star: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedDateString = String()
    
    var priority = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        contentTextField.delegate = self
        Layout.textViewOutLine(contentTextField)
        
        selectedDateLabel.text = selectedDateString
        addButton.layer.cornerRadius = 5
        titleTextField.layer.cornerRadius = 5
        contentTextField.layer.cornerRadius = 5
        categoryLabel.layer.cornerRadius = 15
        contentTextField.text = "内容"
        contentTextField.textColor = .lightGray
        
        imageView.layer.cornerRadius = 10
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
//        imageView.addtar
        //iOS13以前用の擬似ナビバーを生成
        makeNavbar()
        
    }
    
    @objc func imageTapped(){
        print("ピッカー起動")
        showPicker()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
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
        if titleTextField.text! != "" && titleTextField.text!.count < 16
        && contentTextField.text!.count < 201 && priority != 0 {
                let selectedDate = DateUtils.dateFromString(string: selectedDateString, format: "yyyy年MM月dd日")
            
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
                            "userId": currentId,
                            "createdTime": createdTimeUnix,
                            "updatedTime": createdTimeUnix] as [String: Any]
            
                let todoId = TODOS_REF.childByAutoId()
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
    
    // MARK: UIImagePickerControllerDelegate
    // アルバムの起動
    func handleLibrary(){
        print("アルバムの起動")
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
        
        print("カメラの起動")
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
            let resizeImage = pickedImage.resize(size: size)
            self.imageView.image = resizeImage
            if let imageUrl = info[UIImagePickerController.InfoKey.referenceURL] as? NSURL{

                print("DEBUG imageUrl: \(imageUrl)")
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: UITextFieldDelegate
//入力値制限アラート
    func textFieldDidEndEditing(_ textField: UITextField) {
        ToDo.textFieldAlert(titleTextField, addButton, 15)
    }
    
    // キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        ToDo.textViewdAlert(contentTextField, addButton, 200)
    }
    
    
    // MARK: Handlers
    // 写真選択ピッカーの表示
    func showPicker(){
        let alert: UIAlertController = UIAlertController(title: "画像を選択してください", message: nil, preferredStyle:  UIAlertController.Style.actionSheet)

        let deleteAction: UIAlertAction = UIAlertAction(title: "取り消し", style: UIAlertAction.Style.destructive, handler:{
               (action: UIAlertAction!) -> Void in
                print("画像の削除")
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
    //iOS13以前でもナビバーを表示
    func makeNavbar(){
        if #available(iOS 13.0, *) {
        } else {
            let searchBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar-1")!, style: .plain, target: self, action:     #selector(backAction))
            navigationItem.leftBarButtonItem = searchBarButtonItem
        }
    }
}


