//
//  SettingViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/05/29.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
//    @IBOutlet weak var tableView: UITableView!
    var customView: UIView?
    var navHeight: CGFloat?
    var hud = JGProgressHUD(style: .dark)
    var calendarVC: ViewController?
    var tapUIView: UIView?
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        // 土台となるUIView
        self.customView = UIView(frame: CGRect(x: 0, y: 0, width: 220, height: self.view.frame.height - 250 ) )
        self.customView!.backgroundColor = .white
        view.addSubview(customView!)
        
        // 右側の線
        let sideLine = UIView(frame: CGRect(x: 220, y: 0, width: 2, height: self.view.frame.height - 250) )
        sideLine.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230, alpha: 0.9)
        customView?.addSubview(sideLine)
        
        // NavBarの色領域
        let nav = UIView(frame: CGRect(x: 0, y: 0, width: 220, height: navHeight! + statusBarHeight) )
        nav.backgroundColor = UIColor.rgb(red: 245, green: 245, blue: 245, alpha: 0.9)
        customView?.addSubview(nav)
        
        //  NavBar下部の線
        let upperLine = UIView(frame: CGRect(x: 0, y: navHeight! + statusBarHeight, width: 220, height: 2) )
        upperLine.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230, alpha: 0.9)
        self.customView!.addSubview(upperLine)
        
        //　設定ラベル
        let settingLabel = UILabel()
        settingLabel.frame = CGRect(x: 70, y: 30, width: 60, height: 30)
        settingLabel.backgroundColor = .clear
        settingLabel.text = "設定"
        settingLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.customView?.addSubview(settingLabel)
        
        // 設定ボタン
        let backButton  = UIButton()
        backButton.frame = CGRect(x: 170, y: 30, width: 25, height: 25)
        let settingButtonImage = UIImage(named: "gear")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backButton.setImage(settingButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(back), for: UIControl.Event.touchUpInside)
        self.customView!.addSubview(backButton)
        self.customView!.bringSubviewToFront(backButton)
        
        //　ログアウトラベル
        let logoutLabel = UILabel()
        logoutLabel.frame = CGRect(x: 50, y: 90, width: 120, height: 30)
        logoutLabel.backgroundColor = .clear
        logoutLabel.text = "ログアウト"
        logoutLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.customView?.addSubview(logoutLabel)
        
        // ログアウトボタン
        let logoutButton  = UIButton()
        logoutButton.frame = CGRect(x: 170, y: 90, width: 25, height: 25)
        let logoutButtonImage = UIImage(named: "logout")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        logoutButton.setImage(logoutButtonImage, for: .normal)
        logoutButton.tintColor = .black
        logoutButton.addTarget(self, action: #selector(logout), for: UIControl.Event.touchUpInside)
        self.customView!.addSubview(logoutButton)
        self.customView!.bringSubviewToFront(logoutButton)
        
        
        //　背景タップで戻る
        let screenTap = UITapGestureRecognizer(target: self, action: #selector(back))
        screenTap.numberOfTouchesRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(screenTap)
        screenTap.delegate = self
        tapUIView = UIView(frame: CGRect(x: 250, y: 0, width: self.view.frame.width - 250, height: self.view.frame.height) )
        self.view.addSubview(self.tapUIView!)
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if ((touch.view?.isDescendant(of: self.tapUIView!))! ) {
            return true
        }
        return false
    }
    
    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "カテゴリー"
        return cell
    }
    
    
    // MARK: - Handler

    @objc func back(){
        
        self.dismiss(animated: true)
    }
    
    @objc func logout(){
        
        do{
            guard let currentUid = Auth.auth().currentUser?.uid else {return}
            try Auth.auth().signOut()
            USER_REF.child(currentUid).child("isLogin").setValue(false)
            jgprogressSuccess(str: "ログアウトしました")
            self.dismiss(animated: true) {
                print("ログアウトしました")
                self.calendarVC?.renderLogin()
            }
        }catch let error as NSError{
            print("エラー：", error)
        }
    }
    
    // 成功用JGProgress
    func jgprogressSuccess(str: String){
        hud.textLabel.text = str
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0, animated: true)
    }
}
