//
//  LoginViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/05/27.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var emailVerificationButton: UIButton!
    @IBOutlet weak var passResetButton: UIButton!
    
    var loginMode = 0
    
    enum Mode: Int{
        case Login = 0
        case Signin = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
        
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
    }
    
    
    // MARK: EVENT ACTION
    @IBAction func loginOrSignin(_ sender: Any) {
        if(loginMode == Mode.Login.rawValue ){
            
            // ログイン処理
            guard let email = self.emailTextField.text else {return}
            guard let password = self.passwordTextField.text else {return}
            let createdTimeUnix = Date().timeIntervalSince1970
            
//            Auth.auth().signIn(withEmail: email, password: password) { (authResult, err) in
//
//                if let err = err {
//                    print("エラーが起きました", err.localizedDescription)
//                    return
//                }
//            }
            
        }else{
            
            // 新規登録処理
            guard let email = self.emailTextField.text else {return}
            guard let password = self.passwordTextField.text else {return}
            let createdTimeUnix = Date().timeIntervalSince1970
            
            guard signinValidation() else {return}
            
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, err) in
                if let err = err {
                    print("エラーが起きました", err.localizedDescription)
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                guard let uid = authResult?.user.uid else {return}
                
                let dictionaryValue = ["isLogin": true,
                                      "createdTime": createdTimeUnix,
                                      "updatedTime": createdTimeUnix] as [String : Any]
                    
                let value = [uid: dictionaryValue]
                
                USER_REF.updateChildValues(value) { (err, ref) in
                    print("ユーザー登録に成功")
                    let nextVC = ViewController()
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        }
    }
    
    @IBAction func changeMode(_ sender: Any) {
        if (loginMode == Mode.Signin.rawValue ) {
            
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
        }else{
            
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
    }
    
    @IBAction func sendEmailVerification(_ sender: Any) {
        
    }
    
    @IBAction func sendPasswordReset(_ sender: Any) {
        
    }
    
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
    func signinValidation() -> Bool{

        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        let checkPassword = self.checkPasswordTextField.text
        
        
        if password == "" || email == "" || checkPassword == ""{
            print("空白を記入してください")
            return false
        }else if password!.count <  6 {
            print("パスワードは6文字以上です")
            return false
        }else if password != checkPassword {
            print("パスワードと確認用パスワードが一致しません")
            return false
        }
        return true
    }
}
