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

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, TableViewCellDelegate {
    
    
    var navHeight: CGFloat?                 // navBarの高さ
    var hud = JGProgressHUD(style: .dark)   // アラートメッセージ用
    var calendarVC: ViewController?        // 遷移元のViewController
    var tapUIView: UIView?                 // カレンダーエリア
    let headerView = UIView()             // tableView header
    let doneBtn = UIButton()              // tableView header 完了ボタン
    let addBtn = UIButton()               // tableView header 追加ボタン
    var categoryArray = [Category]()      // 表示するカテゴリー名の配列
    var categoryIdArray = [String]()      // tableViewに表示しているカテゴリーID
    var settngHeight: Int?               // 設定ラベルのy位置
    var logoutHeight: Int?               // ログアウトラベルのy位置
    var categoryHeight: Int?             // カテゴリーラベルのy位置
    var tableHeaderHeight: Int?          // テーブルヘッダーのy位置
    let screenHeight = UIScreen.main.bounds.size.height
    let screenWidth = UIScreen.main.bounds.size.width
    var calendarImage = UIImage()        // カレンダー背景
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var backGroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureItems()
        
        congigureBackgound()
       
        tableView.delegate = self
        tableView.dataSource = self
        self.transitioningDelegate = self
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
        cell.textField.text = categoryArray[indexPath.row].name!
        if categoryArray[indexPath.row].name! == "カテゴリー未定" {
            cell.textField.textColor = .lightGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
//        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
//        if categoryArray[indexPath.row].name! == "カテゴリー未定" {
//            cell.textField.text = ""
//        }
    }
    
    // MARK: UITextFieldDelegate
    // textfield 入力直後に呼ばれる
    func textFieldDidEndEditing(cell: TableViewCell, value: String) -> () {
        
    }
    // textfieldタップされた直後
    func textFieldDidBeginEditing(cell: TableViewCell, value: String) {
        doneBtn.isEnabled = false
        self.doneBtn.setTitleColor(.lightGray, for: .normal)
        addBtn.isEnabled = false
        self.addBtn.setTitleColor(.lightGray, for: .normal)
        if cell.textField.text == "カテゴリー未定" {
            cell.textField.text = ""
        }
    }
    // キーボードが閉じる直前
    func textFieldShouldEndEditing(cell: TableViewCell, value: String) {
        let indexPath = tableView.indexPathForRow(at: cell.convert(cell.bounds.origin, to: tableView))
        doneBtn.isEnabled = true
        self.doneBtn.setTitleColor(.black, for: .normal)
        addBtn.isEnabled = true
        self.addBtn.setTitleColor(.black, for: .normal)
        categoryArray[indexPath!.row].name = value
        if value.count == 0 {
            
            self.doneBtn.isEnabled = false
            self.doneBtn.setTitleColor(.lightGray, for: .normal)
            cell.textField.textColor = .lightGray
        }
    }
    
    func textfieldsSouldChangeCharactersIn(cell: TableViewCell, value: String) {
        cell.textField.placeholder = "7文字以内で入力してください"
        let indexPath = tableView.indexPathForRow(at: cell.convert(cell.bounds.origin, to: tableView))
        if value.count < 8 {
            categoryArray[indexPath!.row].name! = value
            self.doneBtn.setTitleColor(.black, for: .normal)
            cell.textField.textColor = .black
        }else{
            self.doneBtn.isEnabled = false
            self.doneBtn.setTitleColor(.lightGray, for: .normal)
            cell.textField.textColor = .lightGray
        }
    }
    
    // MARK: - TransitioningDelegate

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HorizontalAnimator(scrollDirection: .right)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HorizontalAnimator(scrollDirection: .left)
    }
    
    // MARK: EVENT ACTION
    @objc func back(){
        dismiss(animated: true)
    }
    
    @objc func logout(){
        let alert: UIAlertController = UIAlertController(title: "ログアウトしますか?", message: nil, preferredStyle:  UIAlertController.Style.alert)

        let deleteAction: UIAlertAction = UIAlertAction(title: "ログアウト", style: UIAlertAction.Style.destructive, handler:{
               (action: UIAlertAction!) -> Void in
            self.handleLogout()
           })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
               (action: UIAlertAction!) -> Void in
           })

           alert.addAction(cancelAction)
           alert.addAction(deleteAction)

        present(alert, animated: true, completion: nil)
        
    }
    @objc func categoryBtn(){
        if self.tableView.isHidden{
           self.tableView.isHidden = false
            self.headerView.isHidden = false
            doneBtn.isHidden = false
            addBtn.isHidden = false
        }else{
            self.tableView.isHidden = true
            self.headerView.isHidden = true
            doneBtn.isHidden = true
            addBtn.isHidden = true
        }
    }
    func handleLogout(){
        do{
            guard let currentUid = Auth.auth().currentUser?.uid else {return}
            try Auth.auth().signOut()
            USER_REF.child(currentUid).child("isLogin").setValue(false)
            jgprogressSuccess(str: "ログアウトしました")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dismiss(animated: true) {
                    print("ログアウトしました")
                    self.calendarVC?.renderLogin()
                }
            }
        }catch let error as NSError{
            print("エラー：", error)
        }
    }
    // ピッカーの完了タップ時
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
        self.dismiss(animated: true)
    }
    
    @objc func addCategory(){
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        let createdTimeUnix = Date().timeIntervalSince1970
        
        let categoryId = CATEGORIES_REF.child(currentUser).childByAutoId()

        let values = ["name": "カテゴリー未定",
                      "createdTime": createdTimeUnix,
                      "updatedTime": createdTimeUnix] as [String: Any]
        categoryId.updateChildValues(values)
        jgprogressSuccess(str: "カテゴリー追加")
    }
    // MARK: - Handler
    // 成功用JGProgress
    func jgprogressSuccess(str: String){
        hud.textLabel.text = str
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4.0, animated: true)
    }
    
    func configureItems(){
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        if screenHeight >= 812 {
            // iPhone 10以降
            settngHeight = 50
            logoutHeight = 110
            categoryHeight  = 150
            tableHeaderHeight  = 190
        }else{
            // iPhone 10以前
            settngHeight = 30
            logoutHeight = 80
            categoryHeight  = 120
            tableHeaderHeight  = 160
        }
        
        let customWidth = customView.frame.width
        
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
        settingLabel.frame = CGRect(x: 70, y: settngHeight!, width: 60, height: 30)
        settingLabel.backgroundColor = .clear
        settingLabel.text = "設定"
        settingLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.customView?.addSubview(settingLabel)
        
        // 設定ボタン
        let backButton  = UIButton()
        backButton.frame = CGRect(x: 170, y: settngHeight!, width: 25, height: 25)
        let settingButtonImage = UIImage(named: "gear")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backButton.setImage(settingButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(back), for: UIControl.Event.touchUpInside)
        self.customView!.addSubview(backButton)
        self.customView!.bringSubviewToFront(backButton)
        
        //　ログアウトラベル
        let logoutLabel = UIButton()
        logoutLabel.frame = CGRect(x: 40, y: logoutHeight!, width: 120, height: 30)
        logoutLabel.backgroundColor = .clear
        logoutLabel.setTitleColor(.black, for: .normal)
        logoutLabel.setTitle("ログアウト", for: .normal)
        logoutLabel.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        logoutLabel.titleLabel?.textAlignment = NSTextAlignment.center
        logoutLabel.addTarget(self, action: #selector(logout), for: UIControl.Event.touchUpInside)
        self.customView?.addSubview(logoutLabel)
        
        // ログアウトボタン
        let logoutButton  = UIButton()
        logoutButton.frame = CGRect(x: 170, y: logoutHeight!, width: 25, height: 25)
        let logoutButtonImage = UIImage(named: "logout")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        logoutButton.setImage(logoutButtonImage, for: .normal)
        logoutButton.tintColor = .black
        logoutButton.addTarget(self, action: #selector(logout), for: UIControl.Event.touchUpInside)
        self.customView!.addSubview(logoutButton)
        self.customView!.bringSubviewToFront(logoutButton)
        
        //　カテゴリーラベル
        let categoryLabel = UIButton()
        categoryLabel.frame = CGRect(x: 40, y: categoryHeight!, width: 120, height: 30)
        categoryLabel.backgroundColor = .clear
        categoryLabel.setTitleColor(.black, for: .normal)
        categoryLabel.setTitle("カテゴリー", for: .normal)
        categoryLabel.titleLabel?.textAlignment = NSTextAlignment.center
        categoryLabel.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        categoryLabel.addTarget(self, action: #selector(categoryBtn), for: UIControl.Event.touchUpInside)
        self.customView?.addSubview(categoryLabel)
        
        // カテゴリーボタン
        let categoryButton  = UIButton()
        categoryButton.frame = CGRect(x: 170, y: categoryHeight!, width: 25, height: 25)
        let categoryButtonImage = UIImage(named: "edit-icon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        categoryButton.setImage(categoryButtonImage, for: .normal)
        categoryButton.tintColor = .black
        categoryButton.addTarget(self, action: #selector(categoryBtn), for: UIControl.Event.touchUpInside)
        self.customView!.addSubview(categoryButton)
        self.customView!.bringSubviewToFront(categoryButton)
        
        // tableView header
        headerView.frame = CGRect(x: 0, y: tableHeaderHeight!, width: Int(self.tableView.frame.width), height: 60)
        headerView.backgroundColor = UIColor.rgb(red: 225, green: 225, blue: 225, alpha: 0.9)
        self.customView?.addSubview(headerView)
        self.customView!.bringSubviewToFront(headerView)
        
        // 完了ボタン
        self.doneBtn.frame = CGRect(x:Int(customWidth - 50 - 5), y: tableHeaderHeight!, width: 50, height: 30)
        self.doneBtn.setTitle("完了", for: .normal)
        self.doneBtn.setTitleColor(.black, for: .normal)
        self.doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.doneBtn.addTarget(self, action: #selector(editCategory), for: UIControl.Event.touchUpInside)
        self.customView?.addSubview(self.doneBtn)
        self.customView!.bringSubviewToFront(doneBtn)
        // 追加ボタン
        self.addBtn.frame = CGRect(x:5 , y: tableHeaderHeight!, width: 50, height: 30)
        self.addBtn.setTitle("＋", for: .normal)
        self.addBtn.setTitleColor(.black, for: .normal)
        self.addBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.addBtn.addTarget(self, action: #selector(addCategory), for: UIControl.Event.touchUpInside)
        self.customView?.addSubview(self.addBtn)
        self.customView!.bringSubviewToFront(addBtn)
        
        headerView.isHidden = true
        doneBtn.isHidden = true
        addBtn.isHidden = true
        
    }
    // 背景に使用するカレンダー
    func congigureBackgound(){
        let backgroundImageWidth = backGroundImage.frame.width
        let customWidth = customView.frame.width
        let frame = CGRect(x: (screenWidth - backgroundImageWidth), y: 0, width: backgroundImageWidth, height: screenHeight)
        let imgRef = calendarImage.cgImage?.cropping(to: frame)
        let trimImage = UIImage(cgImage: imgRef!, scale: calendarImage.scale, orientation: calendarImage.imageOrientation)
        backGroundImage.image = trimImage
        backGroundImage.layer.shadowColor = UIColor.black.cgColor
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
