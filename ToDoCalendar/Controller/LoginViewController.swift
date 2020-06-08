//
//  LoginViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/05/27.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var emailVerificationButton: UIButton!
    @IBOutlet weak var passResetButton: UIButton!
    
    var loginMode = 0                                             // ログインか新規登録かを判別するフラグ
    var hud = JGProgressHUD(style: .dark)
    var categoryIdKey: String?
    var fromCalendar = false                                    //遷移元を判別するフラグ
    
    enum Mode: Int{
        case Login = 0
        case Signin = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ログイン中であればカレンダー画面に遷移
//        checkLogin()

        self.navigationItem.hidesBackButton = true
        
        emailTextField.keyboardType = .emailAddress
        
        modeButton.setTitleColor(.black, for: .normal)
        let attrText = NSMutableAttributedString(string: "はじめての方は、新規登録から")
        attrText.addAttributes([
            .foregroundColor: UIColor.black
            ], range: NSRange(location:0, length:8)
        )
        attrText.addAttributes([
            .foregroundColor: UIColor.red
            ], range: NSRange(location:8, length:4)
        )
        attrText.addAttributes([
            .foregroundColor: UIColor.black
            ], range: NSRange(location:12, length:2)
        )
        modeButton.setAttributedTitle(attrText, for: .normal)
        
        button.layer.cornerRadius = 5
        checkPasswordTextField.isHidden = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
    }
    
    
    // MARK: EVENT ACTION
    @IBAction func loginOrSignin(_ sender: Any) {
        if(loginMode == Mode.Login.rawValue ){
            // ログイン処理
            loginUser()
        }else{
            // 新規登録処理
            registerUser()
        }
    }
    @IBAction func changeMode(_ sender: Any) {
        if (loginMode == Mode.Signin.rawValue ) {
            
            changeLoginMode()
        }else{
            
            changeRegisterMode()
        }
    }
    
    // アドレス認証
    @IBAction func sendEmailVerification(_ sender: Any) {
        resendVerification(email: emailTextField.text!) { (error) in
            
            if error == nil{
                print("認証用メールを送信しました")
                self.jgprogressSuccess(str: "認証用メールを送信しました")
            }else{
                self.handleSendEmailVwrification(error: error as! NSError)
            }
        }
    }
    // パスワード再設定
    @IBAction func sendPasswordReset(_ sender: Any) {
        if emailTextField.text == ""{
            self.jgprogressError(str: "アドレスを入力して下さい")
            return
        }else{
            resetPassword(email: emailTextField.text!) { (error) in
                
                if error == nil{
                    self.jgprogressSuccess(str: "パスワード再設定メールを送信しました")
                }else{
                    // エラーハンドル
                    self.handlePasswordResetError(error: error as! NSError)
                }
            }
        }
    }

    
//    @IBAction func logout(_ sender: Any) {
//        if Auth.auth().currentUser != nil {
//            do{
//                guard let currentUid = Auth.auth().currentUser?.uid else {return}
//                try Auth.auth().signOut()
//                USER_REF.child(currentUid).child("isLogin").setValue(false)
//                jgprogressError(str: "ログアウトしました")
//            }catch let error as NSError{
//                print("エラー：", error)
//            }
//        }else{
//            jgprogressSuccess(str: "ログインユーザーなし")
//        }
//    }
    
    //MARK: UITextField Delegate
    // キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: Handler
    func checkLogin(){
        
        if Auth.auth().currentUser != nil {
            let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.navigationController?.pushViewController(calendarVC, animated: true)
        }
    }
    
    //ログインUIに変更
    func changeLoginMode(){
        self.navigationItem.title = "ログイン"
        self.button.setTitle("ログイン", for: .normal)
        loginMode = Mode.Login.rawValue
        checkPasswordTextField.isHidden = true
        emailVerificationButton.isHidden = false
        passResetButton.isHidden = false
        modeButton.setTitleColor(.black, for: .normal)
        let str = "はじめての方は、新規登録から"
        let attrText = NSMutableAttributedString(string: str)
        attrText.addAttributes([
            .foregroundColor: UIColor.black
            ], range: NSRange(location:0, length:8)
        )
        attrText.addAttributes([
            .foregroundColor: UIColor.red
            ], range: NSRange(location:8, length:4)
        )
        attrText.addAttributes([
            .foregroundColor: UIColor.black
            ], range: NSRange(location:12, length:2)
        )
        modeButton.setAttributedTitle(attrText, for: .normal)
    }
    
    // 新規作成UIに変更
    func changeRegisterMode(){
        
        self.navigationItem.title = "新規登録"
        self.button.setTitle("登録", for: .normal)
        loginMode = Mode.Signin.rawValue
        checkPasswordTextField.isHidden = false
        emailVerificationButton.isHidden = true
        passResetButton.isHidden = true
        modeButton.setTitleColor(.black, for: .normal)
        let str = "ログインはこちらから"
        let attrText = NSMutableAttributedString(string: str)
        attrText.addAttributes([
            .foregroundColor: UIColor.red
            ], range: NSRange(location:0, length:4)
        )
        attrText.addAttributes([
            .foregroundColor: UIColor.black
            ], range: NSRange(location:4, length:6)
        )
        modeButton.setAttributedTitle(attrText, for: .normal)
    }
    
    // 新規登録バリデーション
    func registerValidation() -> Bool{

        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        let checkPassword = self.checkPasswordTextField.text
                
        if password == "" || email == "" || checkPassword == ""{
            
            jgprogressError(str: "空白を記入してください")
            return false
        }else if password!.count <  6 {
            
            jgprogressError(str: "パスワードは6文字以上です")
            return false
        }else if password != checkPassword {
            
            jgprogressError(str: "パスワードと確認用パスワードが一致しません")
            return false
        }
        return true
    }
    
    
    func loginUser(){
        guard let email = self.emailTextField.text else {return}
        guard let password = self.passwordTextField.text else {return}
        
        guard loginValidation() else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, err) in

            if let err = err {
                // エラーハンドル
                self.handleLoginError(err: err as NSError)
            }else if authResult?.user.isEmailVerified == false{
                // メール認証無効
                self.jgprogressError(str: "送信されたメールを確認してください")
                return
            }else{
                guard let currentUid = authResult?.user.uid else {return}
                // ログイン成功画面遷移
                self.isUserLoggedin(withUserId: currentUid)
            }
        }
        
    }
    
    func registerUser(){
        
        guard let email = self.emailTextField.text else {return}
        guard let password = self.passwordTextField.text else {return}
        let createdTimeUnix = Date().timeIntervalSince1970
        
        guard registerValidation() else {return}
        //　新規登録処理
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, err) in
            if let err = err {
                
                self.handleRegisterError(err: err as NSError)
            }else{
                // サーバーへ新規登録処理
                guard let uid = authResult?.user.uid else {return}
                
                let dictionaryValue = ["isLogin": false,
                                      "createdTime": createdTimeUnix,
                                      "updatedTime": createdTimeUnix] as [String : Any]
                    
                let value = [uid: dictionaryValue]
                
                USER_REF.updateChildValues(value) { (err, ref) in
                    print("ユーザー登録に成功")
                    authResult!.user.sendEmailVerification { (err) in
                        if let err = err{
                            print("エラーが起きました", err.localizedDescription)
                            self.jgprogressError(str: err.localizedDescription)
                        }
                    }
                    
                    self.jgprogressSuccess(str: "確認用メールを送信しました")
                    
                    self.checkTodoInFirebase()
                    
                    // UIをログインに変更する
                    self.changeLoginMode()
                }
            }
            
        }
    }
    
    func handleSendEmailVwrification(error :NSError){
        if let errCode = AuthErrorCode(rawValue: error._code) {
            switch errCode {
            case .userNotFound:
                self.jgprogressError(str: "アカウントが見つかりません")
                print("アカウントが見つかりません")
            case .networkError:
                    self.jgprogressError(str: "通信状態が良くありません")
                    print("通信状態が良くありません")
            case .tooManyRequests:
                self.jgprogressError(str: "複数回呼び出されたため、時間を置いて再度お試しください")
                print("複数回呼び出されたため、時間を置いて再度お試しください")
            default:
                self.jgprogressError(str: "情報が取得できませんでした")
                print("情報が取得できませんでした")
            }
        }
    }
    
    func handlePasswordResetError(error: NSError){

        if let errCode = AuthErrorCode(rawValue: error._code) {
            switch errCode {
            case .invalidRecipientEmail:
                self.jgprogressError(str: "アドレスが正しくありません、確認して下さい")
                print("アドレスが正しくありません、確認して下さい")
            case .invalidSender:
                self.jgprogressError(str: "このメールアドレスは無効です")
                print("このメールアドレスは無効です")
            case .invalidMessagePayload:
                self.jgprogressError(str: "情報が取得できませんでした")
                print("情報が取得できませんでした")
            case .networkError:
                    self.jgprogressError(str: "通信状態が良くありません")
                    print("通信状態が良くありません")
            case .userNotFound:
                self.jgprogressError(str: "このユーザーは存在しません")
                print("このユーザーは存在しません")
            case .tooManyRequests:
                self.jgprogressError(str: "複数回呼び出されたため、時間を置いて再度お試しください")
                print("複数回呼び出されたため、時間を置いて再度お試しください")
            default:
                self.jgprogressError(str: "情報が取得できませんでした")
                print("情報が取得できませんでした")
            }
        }
    }
    
    func handleRegisterError(err: NSError){
        if let errCode = AuthErrorCode(rawValue: err._code) {
            switch errCode {
            case .invalidEmail:
                self.jgprogressError(str: "メールアドレスの形式が違います")
                print("メールアドレスの形式が違います")
                return
            case .emailAlreadyInUse:
                self.jgprogressError(str: "このメールアドレスはすでに使われています")
                print("このメールアドレスはすでに使われています")
                return
            case .networkError:
                    self.jgprogressError(str: "通信状態が良くありません")
                    print("通信状態が良くありません")
                    return
            case .userNotFound:
                self.jgprogressError(str: "このユーザーは存在しません")
                print("このユーザーは存在しません")
                return
            case .tooManyRequests:
                self.jgprogressError(str: "複数回呼び出されたため、時間を置いて再度お試しください")
                print("複数回呼び出されたため、時間を置いて再度お試しください")
                return
            default:
                self.jgprogressError(str: "情報が取得できませんでした")
                print("情報が取得できませんでした")
                return
            }
        }
        self.dismiss(animated: true, completion: nil)
        return
    }
    
    func handleLoginError(err: NSError){

        if let errCode = AuthErrorCode(rawValue: err._code) {
            switch errCode {
            case .invalidEmail:
                self.jgprogressError(str: "メールアドレスの形式が違います")
                print("メールアドレスの形式が違います")
                return
            case .userDisabled:
                self.jgprogressError(str: "このユーザーは使用できません")
                print("このユーザーは使用できません")
                return
            case .wrongPassword:
                self.jgprogressError(str: "パスワードが正しくありません")
                print("パスワードが正しくありません")
                return
            case .networkError:
                    self.jgprogressError(str: "通信状態が良くありません")
                    print("通信状態が良くありません")
                    return
            case .userNotFound:
                self.jgprogressError(str: "このユーザーは存在しません")
                print("このユーザーは存在しません")
                return
            case .tooManyRequests:
                self.jgprogressError(str: "複数回呼び出されたため、時間を置いて再度お試しください")
                print("複数回呼び出されたため、時間を置いて再度お試しください")
                return
            default:
                self.jgprogressError(str: "情報が取得できませんでした")
                print("情報が取得できませんでした")
                return
            }
        }
    }

    func isUserLoggedin(withUserId uid: String){
        
        let updatedTimeUnix = Date().timeIntervalSince1970
        // 既にログイン済かを調べる
        USER_REF.child(uid).child("isLogin").observeSingleEvent(of: .value) { (snapshot) in
            let isLogin = snapshot.value as? Int
            if isLogin == 0{
                // ログイン処理
                USER_REF.child(uid).child("isLogin").setValue(true)
                USER_REF.child(uid).child("updatedTime").setValue(updatedTimeUnix)
                let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                calendarVC.fromLogin = true
                if self.fromCalendar {
                    self.dismiss(animated: true, completion: nil)
                }else{
                    self.navigationController?.pushViewController(calendarVC, animated: true)
                }
            }else{
                self.jgprogressError(str: "ログイン済みのユーザーです")
                return
            }
        }
    }
    
    func loginValidation() -> Bool{
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
                
        if password == "" || email == ""{
            
            jgprogressError(str: "空白を記入してください")
            return false
        }else if password!.count <  6 {
            
            jgprogressError(str: "パスワードは6文字以上です")
            return false
        }
        return true
    }
    
    func resetPassword(email: String, completion: @escaping(_ error: Error?) -> Void){
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    func resendVerification(email: String, completion: @escaping(_ error: Error?) -> Void){
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
    }
    
    // エラー用JGProgress
    func jgprogressError(str: String){
        hud.textLabel.text = str
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0, animated: true)
    }
    
    // 成功用JGProgress
    func jgprogressSuccess(str: String){
        hud.textLabel.text = str
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0, animated: true)
    }
    
// MARK: Realm Database -> Firebase Database
    // Convert Realm to Firebase databsase
    func checkTodoInFirebase(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        // ＊＊＊＊＊＊＊＊＊＊＊＊＊  ここの挙動要確認  ＊＊＊＊＊＊＊＊＊＊＊＊＊
        USER_TODOS_REF.child(currentUid).observeSingleEvent(of: .value) { (snaphot) in
            if snaphot.hasChildren(){
                print("既にデータあり")
            }else{
                self.convertRealmToFirebase(user: currentUid)
                self.createCategory(user: currentUid)
            }
        }
    }

    func convertRealmToFirebase(user user: String){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        let todos = realm.objects(ToDo.self)
        
        for todo in todos {
//            let createdTimeString = DateUtils.stringFromDate(date: todo.dateAt, format: "yyyyMMddHHmmss")
            let createdTimeUnix = todo.dateAt.timeIntervalSince1970
//            let scheduleString = DateUtils.stringFromDate(date: todo.scheduledAt, format: "yyyyMMdd")
            let scheduleUnix = todo.scheduledAt.timeIntervalSince1970
            let scheduleUnixString = String(todo.scheduledAt.timeIntervalSince1970).prefix(10)
            let scheduleString = String(scheduleUnixString)
            
            let values1 = ["title": todo.title,
                          "content": todo.content,
                          "schedule": scheduleUnix,
                          "priority": todo.priority,
                          "isDone": todo.isDone,
                          "imageURL": "",
                          "categoryId": "カテゴリー不明",
                          "userId": user,
                          "createdTime": createdTimeUnix,
                          "updatedTime": createdTimeUnix] as [String: Any]
            
            let todoId = TODOS_REF.childByAutoId()
            guard let todoIdKey = todoId.key else {return}
            todoId.updateChildValues(values1)
            
            USER_TODOS_REF.child(user).updateChildValues([todoIdKey: 1])
            
            CALENDAR_TODOS_REF.child(user).child(scheduleString).updateChildValues([todoIdKey: 1])
            
        }
    }
    
    func createCategory(user user: String){
        
        for i in 1...5 {
            let createdTimeUnix = Date().timeIntervalSince1970
            
            let categoryId = CATEGORIES_REF.child(user).childByAutoId()
            self.categoryIdKey = categoryId.key
            
            let categoryValues = ["name": "カテゴリー未定",
                                  "createdTime": createdTimeUnix,
                                  "updatedTime": createdTimeUnix] as [String: Any]
            
            categoryId.updateChildValues(categoryValues)
        }
    }
        
}
