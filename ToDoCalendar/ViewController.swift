//
//  ViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/01/21.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import RealmSwift
import FSCalendar
import CalculateCalendarLogic
import Firebase
import JGProgressHUD

//下線に色付け
extension FSCalendar {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

class ViewController: UIViewController,FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    

    @IBOutlet weak var myCalendar: FSCalendar!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isDoneCount: UILabel!
    
    var selectedIndexPath: NSIndexPath = NSIndexPath()
    let screenHeight = Int(UIScreen.main.bounds.size.height)
    let screenWidth = Int(UIScreen.main.bounds.size.width)
    var pageMonth:Int?
    var maxPriority = 0                                         // 表示する優先度の初期化
    var todoArray = [FToDo]()
    var filteredTodoArray = [FToDo]()                          // クリックされた日付のToDo
    var selectedDateTodoArray = [FToDo]()                      // 重複しない選択日のToDo配列
    var hud = JGProgressHUD(style: .dark)
    var toggle = false // CustomViewの表示切替用フラグ
    var customView: UIView?
    var postponePickerView = UIPickerView()                    // 先送り表示用のピッカー
    var toolbar = UIToolbar()
    let postponeData = ["1日","2日","3日","4日","5日","6日","7日",]
    var selectedPostponeDay: Int = 1                          //  先延ばしピッカーで選択された日数
    var postponeTodoIndex: Int?
    
    // MARK:  View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        ToDo.makeSampleData(number: 50)
        
//        checkTodoInFirebase()
        configureNavBarleft()
        
        // 先送り用ピッカービューの生成
        configurePickerView()
        
        
        fetchFToDo()
        self.myCalendar.dataSource = self
        self.myCalendar.delegate = self
        tableView.delegate  = self
        tableView.dataSource = self
        myCalendar.scrollDirection = .vertical
        
        let today = Date()
        let todayString = DateUtils.stringFromDate(date: today, format: "yyyy年MM月dd日")
        selectedDateLabel.text = todayString
        showIsDoneTodo()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.todoArray.removeAll()
        fetchFToDo()
        let dateString = selectedDateLabel!.text
        fetchSelectedTodos(date: dateString!)
        showIsDoneTodo()
        if let presented = self.presentedViewController {
            if type(of: presented) == ToDoDetailViewController.self {
                //詳細画面から戻ってきたときreload
                myCalendar.reloadData()
                tableView.reloadData()
            }else if type(of: presented) == SettingViewController.self && Auth.auth().currentUser == nil{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    // Convert Realm to Firebase databsase
    func checkTodoInFirebase(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        USER_TODOS_REF.child(currentUid).observeSingleEvent(of: .value) { (snaphot) in
            if snaphot.hasChildren(){
                print("既にデータあり")
            }else{
                self.convertRealmToFirebase(user: currentUid)
            }
        }
    }
    
    func firebasePlayground(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        USER_TODOS_REF.child(currentUid).observe(.childAdded) { (snaphot) in
                     let todoId = snaphot.key
                     print(todoId)
                    
                    //日付の検索
                    let query = TODOS_REF.queryOrdered(byChild: "schedule").queryStarting(atValue: "20200414").queryEnding(atValue: "20200414")
                    query.observe(.value) { (snapshot) in
                        print(snapshot)
                    }
                    
        //            TODOS_REF.child(todoId).observe(.value) { (snapshot) in
        //                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
        //                let todo = ToDo(todoId: todoId, dictionary: dictionary)
        //                print(todo)
        //            }
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
    
    
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
       }
    
    // MARK: EVENT ACTION
    
    //ToDo追加画面に遷移
    @IBAction func addAction(_ sender: Any) {
        performSegue(withIdentifier: "goAddPage", sender: nil)
    }
    
    //ToDo一覧画面に遷移
    @IBAction func goListAction(_ sender: Any) {
        performSegue(withIdentifier: "goListPage", sender: nil)
    }
    
    @IBAction func openSettingView(_ sender: Any) {
//        let settingView = UINib(nibName: "SettingView", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? UIView
//        view.addSubview(settingView!)
    }
    
    
    // MARK:  - CaluculateCalendarLogic
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    // date型 -> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }

    //曜日判定(日曜日:1 〜 土曜日:7)
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    //月判定
    func getMonthIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.month, from: date)
    }


    // MARK: FSCalendar Delegate
    //日付をタップした時の処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Void {
        
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        selectedDateLabel.text = "\(year)年\(month)月\(day)日"
        tableView.reloadData()
        showIsDoneTodo()
//        print("月：\(getMonthIdx(date))")
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    //カレンダーの月送りで月を取得
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentPage:Date = calendar.currentPage
        let modifiedCurrentPage = Calendar.current.date(byAdding: .hour, value: 9, to: currentPage)  //9時間足した日付
        let monthString = DateUtils.stringFromDate(date: modifiedCurrentPage!, format: "MM")
        pageMonth = Int(monthString)!
        
        let realm = try! Realm()
        let month = realm.objects(DateUtils.self).first
        //pageMonthをDB上で更新していく
        if month?.month != nil {
            try! realm.write {
                month!.month = pageMonth!
            }
        }
    }
    
    
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        let weekday = self.getWeekIdx(date)
        let today = Date()
        let thisMonth = Calendar.current.component(.month, from: today)
        var pageMonth = realm.objects(DateUtils.self).first?.month
        if pageMonth != nil {
            next
        }  else {
            let month = DateUtils()
            month.month = Calendar.current.component(.month, from: Date()) //今月を登録
            try! realm.write {
              realm.add(month)
            }
            pageMonth = realm.objects(DateUtils.self).first?.month
        }
        let selectedMonth = Calendar.current.component(.month, from: date)
        let selectedDay = Calendar.current.component(.day, from: date)
        
        //祝日判定をする（祝日は赤色で表示する）
        if selectedMonth == thisMonth && (self.judgeHoliday(date) || weekday == 1 || weekday == 7){ //今月かつ土日祝日
                return UIColor.red
        } else if selectedMonth != thisMonth && (self.judgeHoliday(date) || weekday == 1 || weekday == 7) { //今月以外で土日祝日
                return UIColor.red
        }
        return nil
        
    }
    
    // 日の始まりと終わりを取得
    private func getBeginingAndEndOfDay(_ date:Date) -> (begining: Date , end: Date) {
        let begining = Calendar(identifier: .gregorian).startOfDay(for: date)
        let end = begining + 24*60*60
        return (begining, end)
    }
    
    //優先度(星しるし)の表示
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
//        guard let currentUser = Auth.auth().currentUser?.uid else { return nil}
        
        
        // 最大優先度の取得 (Firebase)
        let scheduleUnixString = String(date.timeIntervalSince1970).prefix(10)
        let scheduleString = String(scheduleUnixString)
        for todo in todoArray {
            if (String(todo.scheduled!) == scheduleString) && (todo.priority! > maxPriority && todo.isDone == false) {
                maxPriority = todo.priority
            }
        }
        switch self.maxPriority {
        case 1:
            self.maxPriority = 0
            return "⭐️"
        case 2:
            self.maxPriority = 0
            return "⭐️⭐️"
        case 3:
            self.maxPriority = 0
            return "⭐️⭐️⭐️"
        default:
            return ""
        }
    }
    
    // MARK: UITableViewDelegate
    
    //テーブルセルのセル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateString = selectedDateLabel!.text
        
        // Firebaseより取得
        fetchSelectedTodos(date: dateString!)
        
        return selectedDateTodoArray.count
    }
    

    //Cellの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dateString = selectedDateLabel!.text
        
        fetchSelectedTodos(date: dateString!)
        
        if self.selectedDateTodoArray.count > indexPath.row {
            let todo = self.selectedDateTodoArray[indexPath.row]
            if todo.title.count >= 11 {
                let longTitle = todo.title.prefix(10)
                cell.textLabel!.text = longTitle + "..."
            } else {
                cell.textLabel!.text = todo.title
            }
            switch todo.priority {
            case 1:
                cell.detailTextLabel?.text = "★"
            case 2:
                cell.detailTextLabel?.text = "★★"
            case 3:
                cell.detailTextLabel?.text = "★★★"
            default:
                cell.detailTextLabel?.text = ""
            }
            if todo.isDone == true{
                cell.textLabel?.textColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
                cell.detailTextLabel?.textColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
            } else {
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
            }
            Layout.calendarTableCellFont(cell: cell)
            return cell
        }else {
            return cell
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

            return tableView.layer.bounds.height/5
    }
    
    //セルクリックで詳細画面へ遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        self.selectedIndexPath = indexPath as NSIndexPath
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goDetailPage", sender: nil)
    }
    
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    // 完了/未完了処理
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let dateString = self.selectedDateLabel!.text
        fetchSelectedTodos(date: dateString!)
        let isDoneAction = UIContextualAction(style: .normal,
                                        title: selectedDateTodoArray[indexPath.row].isDone ? "未完了" : "完了") { (action, view, completionHandler) in
                                          // 処理を実行
                                          self.handleSwitchIsDone(indexPath: indexPath)
                                          self.myCalendar.reloadData()
                                          tableView.reloadData()
              completionHandler(true)
        }
        let postponeAction = UIContextualAction(style: .normal,
                                        title: "先送り") { (action, view, completionHandler) in
                                            
                                          // 処理を実行
                                          self.postponeTodoIndex = indexPath.row
                                          self.toggleShowPostpone()
                                          self.myCalendar.reloadData()
                                          tableView.reloadData()
              completionHandler(true)
        }
        postponeAction.backgroundColor = UIColor.rgb(red: 113, green: 155, blue: 128, alpha: 1)
        
        let configuration: UISwipeActionsConfiguration?
        if selectedDateTodoArray[indexPath.row].isDone{
            configuration = UISwipeActionsConfiguration(actions: [isDoneAction])
        }else{
            configuration = UISwipeActionsConfiguration(actions: [isDoneAction, postponeAction])
        }
        configuration!.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    
    //値の受け渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goAddPage" {
            let nextVC = segue.destination as! AddToDoViewController
            nextVC.selectedDateString = selectedDateLabel.text!
        } else if segue.identifier == "goDetailPage" {
            let nextVC = segue.destination as! ToDoDetailViewController
            let indexPath = self.selectedIndexPath
            let dateString = selectedDateLabel!.text
            fetchSelectedTodos(date: dateString!)
            let ftodo = selectedDateTodoArray[indexPath.row]
            nextVC.todo = ftodo
            if #available(iOS 13, *) {
            } else {
                nextVC.modalPresentationStyle = .pageSheet
            }
        }
    }
    
    // MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return postponeData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.text = self.postponeData[row]
        pickerLabel.font = UIFont.systemFont(ofSize: 22)
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPostponeDay = row + 1
    }
    
    // MARK: Handlers
    //完了済件数の表示
    func showIsDoneTodo(){
        var done:Int = 0
        var total:Int = 0
        let dateString = self.selectedDateLabel!.text
        fetchSelectedTodos(date: dateString!)
        for todo in selectedDateTodoArray{
            if todo.isDone { done += 1 }
        }
        total = selectedDateTodoArray.count
        if total > 0 {
            isDoneCount.text = "完了済　\(done)/ \(total)"
        } else {
            isDoneCount.text = ""
        }
        return
    }
    
    func handleSwitchIsDone(indexPath: IndexPath){
        guard let todoId = self.selectedDateTodoArray[indexPath.row].todoId else {return}
        let updatedTimeUnix = Date().timeIntervalSince1970
        
        if self.selectedDateTodoArray[indexPath.row].isDone {
        
            TODOS_REF.child(todoId).child("isDone").setValue(false)
            TODOS_REF.child(todoId).child("updatedTime").setValue(updatedTimeUnix)
            self.selectedDateTodoArray[indexPath.row].isDone = false
        } else {
            
            TODOS_REF.child(todoId).child("isDone").setValue(true)
            TODOS_REF.child(todoId).child("updatedTime").setValue(updatedTimeUnix)
            self.selectedDateTodoArray[indexPath.row].isDone = true
        }
        self.showIsDoneTodo()
    }
    
    func configureNavBarleft(){
        
        let gearImage = UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate)
        let reSize:CGSize = CGSize.init(width: 25, height:25)
        let settingImage = gearImage!.resize(size: reSize)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: settingImage, style: .plain, target: self, action: #selector(showSetting))
        
    }
    
    @objc func showSetting(){
        let navBarHeight =  self.navigationController?.navigationBar.frame.size.height
        let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        settingVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        settingVC.modalPresentationStyle = .overCurrentContext
        settingVC.navHeight = navBarHeight
        settingVC.calendarVC = self
//        settingVC.view.backgroundColor = UIColor.clear
        self.present(settingVC, animated: true, completion: nil)
    }
    
    // 設定UIViewの表示切替 
    @objc func showUiview(){
        if self.toggle{
            customView?.isHidden = true
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.toggle = false
        }else{
            customView!.isHidden = false
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.toggle = true
        }
        
    }
    
    // ログアウト処理
    @objc func logout(){
        
        do{
            let updatedTimeUnix = Date().timeIntervalSince1970
            guard let currentUid = Auth.auth().currentUser?.uid else {return}
            try Auth.auth().signOut()
            USER_REF.child(currentUid).child("isLogin").setValue(false)
            USER_REF.child(currentUid).child("updatedTime").setValue(updatedTimeUnix)
            jgprogressError(str: "ユーザーログアウト")
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.popViewController(animated: true)
        }catch let error as NSError{
            print("エラー：", error)
        }
    }
    
    func renderLogin(){
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.popViewController(animated: true)
    }
    
    // 先延ばしピッカーの表示切替
    @objc func toggleShowPostpone(){
        if self.postponePickerView.isHidden == false{
            
            self.postponePickerView.isHidden = true
            self.toolbar.isHidden = true
        }else{
            self.postponePickerView.isHidden = false
            self.toolbar.isHidden = false
        }
    }
    
    // 先延ばし機能の実行
    @objc func handlePostpone(){

        let updatedTimeUnix = Date().timeIntervalSince1970
        let todoId = self.selectedDateTodoArray[self.postponeTodoIndex!].todoId
        let baseDateIntUnix = self.selectedDateTodoArray[self.postponeTodoIndex!].scheduled
        let baseDate = Date(timeIntervalSince1970: Double(baseDateIntUnix!))
        let modifiedDate = Calendar.current.date(byAdding: .day, value: self.selectedPostponeDay, to: baseDate)!
        let modifiedUnixDate = modifiedDate.timeIntervalSince1970
        
        TODOS_REF.child(todoId!).child("schedule").setValue(modifiedUnixDate)
        TODOS_REF.child(todoId!).child("updatedTime").setValue(updatedTimeUnix)
        self.selectedDateTodoArray[self.postponeTodoIndex!].scheduled = Int(modifiedUnixDate)
        
        self.myCalendar.reloadData()
        self.tableView.reloadData()
        toggleShowPostpone()
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
    
    func configurePickerView(){
        // ツールバーの生成
        let cancell = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(toggleShowPostpone))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(handlePostpone))
        toolbar.setItems([cancell, spacelItem, doneItem], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.frame = CGRect(x: 0, y: screenHeight-150-35, width: screenWidth, height: 35)
        toolbar.backgroundColor = .white
        view.addSubview(toolbar)
        toolbar.isHidden = true
        
        postponePickerView.delegate = self
        postponePickerView.dataSource = self
        let pickerWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        postponePickerView.frame = CGRect(x: 0, y: screenHeight - 150, width: pickerWidth, height: 150)
        postponePickerView.backgroundColor  = UIColor.rgb(red: 230, green: 230, blue: 230, alpha: 1)
        view.addSubview(postponePickerView)
        postponePickerView.isHidden = true
    }
    
    // MARK: API
    
    func fetchFToDo(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        USER_TODOS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let todoId = snapshot.key
            
            TODOS_REF.child(todoId).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
                
                let todo = FToDo(todoId: todoId, dictionary: dictionary)
                self.todoArray.append(todo)
                self.myCalendar.reloadData()
                self.tableView.reloadData()
            }
        }
    }
    
    // タップされた日付のToDoをselectedDateTodoArrayに用意する
    func fetchSelectedTodos(date selectedDate: String){
        var todoIdCheck = [String]()
        
        selectedDateTodoArray.removeAll()
        let selectedDate = DateUtils.dateFromString(string: selectedDate, format: "yyyy年MM月dd日")
        let scheduleUnixString = String(selectedDate.timeIntervalSince1970).prefix(10)
        let scheduleString = String(scheduleUnixString)
        self.filteredTodoArray = self.todoArray.filter({$0.scheduled == Int(scheduleString)})
        for todo in filteredTodoArray{
            
            if !todoIdCheck.contains(todo.todoId){
                todoIdCheck.append(todo.todoId)
                selectedDateTodoArray.append(todo)
            }
        }
    }
    
    
}

