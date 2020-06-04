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

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, TableViewCellDelegate {
    
    var navHeight: CGFloat?                 // navBarの高さ
    var hud = JGProgressHUD(style: .dark)   // アラートメッセージ用
    var calendarVC: ViewController?        // 遷移元のViewController
    var tapUIView: UIView?                 // カレンダーエリア
    let headerView = UIView()                 // tableView header
    let doneBtn = UIButton()              // tableView header 完了ボタン
    @IBOutlet weak var tableView: UITableView!
    var categoryArray = [Category]()      // 表示するカテゴリー名の配列
    var categoryIdArray = [String]()        // tableViewに表示しているカテゴリーID
    
    @IBOutlet weak var customView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureItems()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchCategories()
        //　背景タップで戻る
        let screenTap = UITapGestureRecognizer(target: self, action: #selector(back))
        screenTap.numberOfTouchesRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(screenTap)
        screenTap.delegate = self
        tapUIView = UIView(frame: CGRect(x: 250, y: 0, width: self.view.frame.width - 250, height: self.view.frame.height) )
        self.view.addSubview(self.tapUIView!)
        
        self.tableView.isHidden = true
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if ((touch.view?.isDescendant(of: self.tapUIView!))! ) {
            return true
        }
        return false
    }
    
    // MARK: UITableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        cell.delegate = self
        if categoryArray.count > 0{
            cell.textField.text = categoryArray[indexPath.row].name!
        }
        return cell
    }
    
    // MARK: UITextFieldDelegate
    // textfield 入力直後に呼ばれる
    func textFieldDidEndEditing(cell: TableViewCell, value: String) -> () {
        let indexPath = tableView.indexPathForRow(at: cell.convert(cell.bounds.origin, to: tableView))
        categoryArray[indexPath!.row].name! = value
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    // MARK: EVENT ACTION
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
    @objc func categoryBtn(){
        if self.tableView.isHidden{
           self.tableView.isHidden = false
            self.headerView.isHidden = false
            doneBtn.isHidden = false
        }else{
            self.tableView.isHidden = true
            self.headerView.isHidden = true
            doneBtn.isHidden = true
        }
    }
    
    @objc func editCategory(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        let updateTime = Date().timeIntervalSince1970
        
        var i = 0
        for category in self.categoryArray {
            
            let values = ["name": category.name,
                          "createdTime": category.createdTime,
                          "updatedTime": updateTime] as [String: Any]
            
            var categoryId = categoryIdArray[i]
            CATEGORIES_REF.child(currentUid).child(categoryId).updateChildValues(values)
            i += 1
        }
        print("カテゴリーの編集完了処理")
        self.dismiss(animated: true)
    }
    // MARK: - Handler
    // 成功用JGProgress
    func jgprogressSuccess(str: String){
        hud.textLabel.text = str
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0, animated: true)
    }
    
    func configureItems(){
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        // 土台となるUIView
//        self.customView = UIView(frame: CGRect(x: 0, y: 0, width: 220, height: self.view.frame.height ) )
//        self.customView!.backgroundColor = .white
//        
//        view.addSubview(customView!)
        
        // 右側の線
        let sideLine = UIView(frame: CGRect(x: 220, y: 0, width: 2, height: self.view.frame.height) )
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
        logoutLabel.frame = CGRect(x: 50, y: 80, width: 120, height: 30)
        logoutLabel.backgroundColor = .clear
        logoutLabel.text = "ログアウト"
        logoutLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.customView?.addSubview(logoutLabel)
        
        // ログアウトボタン
        let logoutButton  = UIButton()
        logoutButton.frame = CGRect(x: 170, y: 80, width: 25, height: 25)
        let logoutButtonImage = UIImage(named: "logout")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        logoutButton.setImage(logoutButtonImage, for: .normal)
        logoutButton.tintColor = .black
        logoutButton.addTarget(self, action: #selector(logout), for: UIControl.Event.touchUpInside)
        self.customView!.addSubview(logoutButton)
        self.customView!.bringSubviewToFront(logoutButton)
        
        //　カテゴリーラベル
        let categoryLabel = UILabel()
        categoryLabel.frame = CGRect(x: 50, y: 120, width: 120, height: 30)
        categoryLabel.backgroundColor = .clear
        categoryLabel.text = "カテゴリー"
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.customView?.addSubview(categoryLabel)
        
        // カテゴリーボタン
        let categoryButton  = UIButton()
        categoryButton.frame = CGRect(x: 170, y: 120, width: 25, height: 25)
        let categoryButtonImage = UIImage(named: "edit-icon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        categoryButton.setImage(categoryButtonImage, for: .normal)
        categoryButton.tintColor = .black
        categoryButton.addTarget(self, action: #selector(categoryBtn), for: UIControl.Event.touchUpInside)
        self.customView!.addSubview(categoryButton)
        self.customView!.bringSubviewToFront(categoryButton)
        
        // tableView header
        headerView.frame = CGRect(x: 0, y: 160, width: self.tableView.bounds.width, height: 60)
        headerView.backgroundColor = UIColor.rgb(red: 225, green: 225, blue: 225, alpha: 0.9)
        self.customView?.addSubview(headerView)
        self.customView!.bringSubviewToFront(headerView)
        
        self.doneBtn.frame = CGRect(x:160 , y: 160, width: 50, height: 30)
        self.doneBtn.setTitle("完了", for: .normal)
        self.doneBtn.setTitleColor(.black, for: .normal)
        self.doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.doneBtn.addTarget(self, action: #selector(editCategory), for: UIControl.Event.touchUpInside)
        self.customView?.addSubview(self.doneBtn)
        self.customView!.bringSubviewToFront(doneBtn)
        headerView.isHidden = true
        doneBtn.isHidden = true
        
    }
    
    // MARK: API
    func fetchCategories(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        CATEGORIES_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
            let categoryId = snapshot.key as String
            let category = Category(dictionary: dictionary)
            
            self.categoryArray.append(category)
            self.categoryIdArray.append(categoryId)
            self.tableView.reloadData()
        }
    }
}
