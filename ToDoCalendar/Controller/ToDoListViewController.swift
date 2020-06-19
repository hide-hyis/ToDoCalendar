
//  ToDoListViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/02/06.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class ToDoListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CatchProtocol, DetailProtocol {
    
    
    
    @IBOutlet weak var detailTextView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    @IBOutlet weak var isDoneSegment: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    
    var priority: Int?
    var segmentIndex:Int = 0
    var isDoneSegmentIndex:Int = 0
    let screenHeight = Int(UIScreen.main.bounds.size.height)
    let screenWidth = Int(UIScreen.main.bounds.size.width)
    var todoArray = [FToDo]()               // ユーザーが持つtodo全件
    var resultArray = [FToDo]()             // 並び替えfilter後のtodo全件
    var todo:FToDo?                         //タップされたtodo項目
    var isDoneCheck = false                 // 未完/完了タブの切替
    var asc = true                         // 逆順フラグ
    var searchKeyWord = [String: Any]()    //検索キーワード
    var selectedIndexPath: NSIndexPath = NSIndexPath()
    var postponePickerView = UIPickerView()                    // 先送り表示用のピッカー
    var toolbar = UIToolbar()
    let postponeData = ["1日","2日","3日","4日","5日","6日","7日",]
    var selectedPostponeDay: Int = 1                          //  先延ばしピッカーで選択された日数
    var postponeTodoIndex: Int?
    var dabCount: Int?
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFToDo()
        self.navigationItem.hidesBackButton = true
        tableView.delegate = self
        tableView.dataSource = self
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.cornerRadius = 20.0
        detailTextView.layer.borderColor = UIColor.black.cgColor
        swipeGesture.isEnabled = false
        Layout.buttonBorderRadius(buttono: clearButton, width: 1.0, radius: 10.0)
        Layout.buttonBorderRadius(buttono: searchButton, width: 1.0, radius: 10.0)
        
        
        configureSegment()
        
        // 先送り用ピッカービューの生成
        configurePickerView()
        //iOS13以前でもナビバーを表示
        makeNavbar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    // 編集画面からの情報を反映する
    func modifiedTableView(){
//        if todoArray.count != 0 {dabCount = todoArray.count}
        todoArray.removeAll()
        fetchFToDo()
        tableView.reloadData()
    }
    func catchtable(editKeys: [String: String]) {
        titleLabel.text = editKeys["title"]
        contentLabel.text = editKeys["content"]
        switch editKeys["priority"] {
        case "1":
            priorityLabel.text = "★"
        case "2":
            priorityLabel.text = "★★"
        case "3":
            priorityLabel.text = "★★★"
        default:
            priorityLabel.text = ""
        }
        if editKeys["scheduledAt"] == "予定日" {
            dateLabel.text = "予定日"
        } else {
           let scheduledAtString = ToDo.dateStringTodae(string: editKeys["scheduledAt"]!)
           dateLabel.text = "\(scheduledAtString.0)/\(scheduledAtString.1)/\(scheduledAtString.2)"
        }
        tableView.reloadData()
    }
    
    
    
    // MARK: EVENT ACTION
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //ソートの切替
    @IBAction func segmentAction(_ sender: Any) {
//        let search = realm.objects(Search.self).first
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(" ", forKey: "sortKey")
            tableView.reloadData()
        case 1:
            UserDefaults.standard.set("schedule", forKey: "sortKey")
            tableView.reloadData()
        case 2:
            UserDefaults.standard.set("priority", forKey: "sortKey")
            tableView.reloadData()
        default:
            return
        }
    }
    
//    未完/完了セグメント切替処理
    @IBAction func switchIsDone(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(false, forKey: "isDoneCheck")
            tableView.reloadData()
        case 1:
            UserDefaults.standard.set(true, forKey: "isDoneCheck")
            tableView.reloadData()
        default:
            return
        }
    }
    
    //逆順切替
    @IBAction func sortRev(_ sender: Any) {
        
        if asc {
            asc = false
        }else{
            asc = true
        }
        tableView.reloadData()
    }
    
    //上スワイプで詳細画面に遷移
    @IBAction func swipeUpAction(_ sender: Any) {
            performSegue(withIdentifier: "goDetailPage", sender: nil)
    }
    
    //値の受渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetailPage"{
            let nextVC = segue.destination as! ToDoDetailViewController
            let dateComponentsArray = dateLabel!.text!.components(separatedBy: "/")
            let datestr = "\(dateComponentsArray[0])年\(dateComponentsArray[1])月\(dateComponentsArray[2])日"
            nextVC.todo = self.todo
            nextVC.listVC = self
            nextVC.delegate = self
        }else if segue.identifier == "goSearchPage" {
            let nextVC = segue.destination as! SearchViewController
            nextVC.delegate = self
        }
    }
    
    //検索内容を空にするクリアボタン
    @IBAction func clearAction(_ sender: Any) {
        if !searchKeyWord.isEmpty {
            searchKeyWord.removeAll()
            tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                return tableView.layer.bounds.height/5
    }
    
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        makeResultArray()
        return resultArray.count
    }
    
    //セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        todoArrayForCell(cell: cell, indexPath: indexPath)
        
        Layout.listTableCellFont(cell: cell)
        return cell
    }
    //セルクリックで下部詳細表示
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        self.selectedIndexPath = indexPath as NSIndexPath
         makeResultArray()
         todo = resultArray[indexPath.row]
        
        
        titleLabel.text = self.todo!.title
        contentLabel.text = self.todo!.content
        let day = Date(timeIntervalSince1970: Double(todo!.scheduled))
        dateLabel.text = DateUtils.stringFromDate(date: day, format: "YYYY/MM/dd")
        switch todo!.priority {
        case 1:
            priorityLabel.text = "★"
        case 2:
            priorityLabel.text = "★★"
        case 3:
            priorityLabel.text = "★★★"
        default:
            priorityLabel.text = ""
        }
        if todo!.isDone == true {
            titleLabel.textColor = UIColor.gray; contentLabel.textColor = UIColor.gray
            dateLabel.textColor = UIColor.gray; priorityLabel.textColor = UIColor.gray
        } else {
            titleLabel.textColor = UIColor.black; contentLabel.textColor = UIColor.black
            dateLabel.textColor = UIColor.black;  priorityLabel.textColor = UIColor.black
        }
        swipeGesture.isEnabled = true
    }
    
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    // 完了/未完了処理
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        makeResultArray()
        
        let isDoneAction = UIContextualAction(style: .normal,
                                        title: resultArray[indexPath.row].isDone ? "未完了" : "完了") { (action, view, completionHandler) in
                                            
              // 完了切替処理を実行(Firebase)
              self.handleSwitchIsDone(indexPath: indexPath)
             
              tableView.reloadData()
              completionHandler(true)
        }
        let postponeAction = UIContextualAction(style: .normal,
                                        title: "先送り") { (action, view, completionHandler) in
                                            
                                          // 処理を実行
                                          self.postponeTodoIndex = indexPath.row
                                          self.toggleShowPostpone()
                                          tableView.reloadData()
              completionHandler(true)
        }
        postponeAction.backgroundColor = UIColor.rgb(red: 113, green: 155, blue: 128, alpha: 1)
        
        let configuration: UISwipeActionsConfiguration?
        if resultArray[indexPath.row].isDone{
            configuration = UISwipeActionsConfiguration(actions: [isDoneAction])
        }else{
            configuration = UISwipeActionsConfiguration(actions: [isDoneAction, postponeAction])
        }
        configuration!.performsFirstActionWithFullSwipe = false
        return configuration
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
    // MARK: CatchProtocol
    //検索ワードの受取
    func catchData(key: [String : String]) {
        searchKeyWord.removeAll()
        if key["title"] != nil { searchKeyWord["title"] = key["title"] }
        if key["content"] != nil && key["content"] != "内容" { searchKeyWord["content"] = key["content"] }
        if key["categoryId"] != nil { searchKeyWord["categoryId"] = key["categoryId"] }
        if key["priority"] != nil { searchKeyWord["priority"] = key["priority"] }
        if key["dateFrom"] != nil { searchKeyWord["dateFrom"] = key["dateFrom"] }
        if key["dateTo"] != nil { searchKeyWord["dateTo"] = key["dateTo"] }
        tableView.reloadData()
        titleLabel.text = "タイトル"
        contentLabel.text = "内容"
        dateLabel.text = "予定日"
        priorityLabel.text = "★"
        print("searchKey: \(searchKeyWord)")
    }
    
    // MARK: - Handler
    
    func configurePickerView(){
        // ツールバーの生成
        let cancell = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancellShowPostpone))
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
    
    // 先延ばしピッカーの表示切替
    func toggleShowPostpone(){
        if self.postponePickerView.isHidden == false{
            
            self.postponePickerView.isHidden = true
            self.toolbar.isHidden = true
        }else{
            self.postponePickerView.isHidden = false
            self.toolbar.isHidden = false
        }
    }
    
    @objc func cancellShowPostpone(){
        if self.postponePickerView.isHidden == false{
            
            self.postponePickerView.isHidden = true
            self.toolbar.isHidden = true
        }
    }
    // 先延ばし機能の実行
    @objc func handlePostpone(){
        
        let updatedTimeUnix = Date().timeIntervalSince1970
        let todoId = self.resultArray[self.postponeTodoIndex!].todoId
        let baseDateIntUnix = self.resultArray[self.postponeTodoIndex!].scheduled
        let baseDate = Date(timeIntervalSince1970: Double(baseDateIntUnix!))
        let modifiedDate = Calendar.current.date(byAdding: .day, value: self.selectedPostponeDay, to: baseDate)!
        let modifiedUnixDate = modifiedDate.timeIntervalSince1970
        
        TODOS_REF.child(todoId!).child("schedule").setValue(modifiedUnixDate)
        TODOS_REF.child(todoId!).child("updatedTime").setValue(updatedTimeUnix)
        self.resultArray[self.postponeTodoIndex!].scheduled = Int(modifiedUnixDate)
        
        self.tableView.reloadData()
        
        toggleShowPostpone()
    }
    
    func configureSegment(){
//        let search = realm.objects(Search.self).first
        //sortセグメントの初期表示
        let sort = UserDefaults.standard.string(forKey: "sortKey")
        switch  sort{
        case " ":
            segmentIndex = 0
        case "schedule":
            segmentIndex = 1
        case "priority":
            segmentIndex = 2
        default:
            segmentIndex = 0
        }
        sortSegment.selectedSegmentIndex = segmentIndex
        
        //未完,完了セグメントの初期表示
        let isDoneCheck = UserDefaults.standard.bool(forKey: "isDoneCheck")
        switch isDoneCheck {
        case false:
            isDoneSegmentIndex = 0
        case true:
            isDoneSegmentIndex = 1
        }
        isDoneSegment.selectedSegmentIndex = isDoneSegmentIndex
    }
    

    // TableView表示のcellをFirebaseのデータから当てはめる
    func todoArrayForCell(cell: UITableViewCell, indexPath: IndexPath){
        makeResultArray()
        if resultArray.isEmpty {return}
        
//        let preKey = NSPredicate(format: "title CONTAINS[c] %@", "会議")
//        let afterArray = (resultArray as NSArray).filtered(using: preKey)
//        print("resultArray: \(resultArray.count)件\n検索結果:\n\(afterArray)")
        
        let todo = resultArray[indexPath.row]
        let day = Date(timeIntervalSince1970: Double(todo.scheduled))
        let date = DateUtils.stringFromDate(date: day, format: "YYYY/MM/dd")
        if todo.title.count >= 11 {
            let longTitle = todo.title.prefix(10)
            cell.textLabel!.text = longTitle + "..."
        } else {
            cell.textLabel!.text = todo.title
        }
        switch todo.priority {
        case 1:
            cell.detailTextLabel?.text = "\(date)           ★"
        case 2:
            cell.detailTextLabel?.text = "\(date)       ★★"
        case 3:
            cell.detailTextLabel?.text = "\(date)   ★★★"
        default:
            cell.detailTextLabel?.text = ""
        }
        if todo.isDone == true{
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        } else {
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        }
    }
    
    func makeResultArray(){
        
        isDoneCheck = UserDefaults.standard.bool(forKey: "isDoneCheck")
        resultArray = todoArray.filter({$0.isDone == isDoneCheck})
        
        //検索キーワードがあれば検索処理
        if !searchKeyWord.isEmpty{
            resultArrayForSearch()
        }
        
        // 一覧表示用のソート
        switch UserDefaults.standard.string(forKey: "sortKey") {
        case "createdTime":
            self.resultArray.sort { (todo1, todo2) -> Bool in
                return todo1.createdTime < todo2.createdTime
            }
        case "schedule":
            self.resultArray.sort { (todo1, todo2) -> Bool in
                return todo1.scheduled < todo2.scheduled
            }
        case "priority":
            self.resultArray.sort { (todo1, todo2) -> Bool in
                return todo1.priority < todo2.priority
            }
        default:
            self.resultArray.sort { (todo1, todo2) -> Bool in
                return todo1.createdTime > todo2.createdTime
            }
        }
        // 逆順
        if !asc{
            resultArray.reverse()
        }
    }
    
    // 検索処理
    func resultArrayForSearch(){
        
            if (searchKeyWord["title"] != nil){
                resultArray = resultArray.filter({ $0.title.contains(searchKeyWord["title"] as! String) })
            }
            if (searchKeyWord["content"] != nil){
                resultArray = resultArray.filter({ $0.content.contains(searchKeyWord["content"] as! String) })
            }
            if (searchKeyWord["categoryId"] != nil){
                resultArray = resultArray.filter({ $0.categoryId == (searchKeyWord["categoryId"] as! String) })
            }
            if (searchKeyWord["priority"] != nil){
                let priorityKey = searchKeyWord["priority"] as! String
                resultArray = resultArray.filter({ $0.priority == Int(priorityKey) })
            }
            if (searchKeyWord["dateFrom"] != nil && searchKeyWord["dateTo"] != nil){
                let dateFrom = unixFromDateString(date: searchKeyWord["dateFrom"])
                let dateTo = unixFromDateString(date: searchKeyWord["dateTo"])
                
                resultArray = resultArray.filter({ $0.scheduled >= dateFrom && $0.scheduled <= dateTo })
            } else if (searchKeyWord["dateFrom"] != nil){
                let dateFrom = unixFromDateString(date: searchKeyWord["dateFrom"])
                
                resultArray = resultArray.filter({ $0.scheduled >= dateFrom })
                if !resultArray.isEmpty{
                    for todo in resultArray{
                        print("title: \(todo.title)予定日: \( NSDate(timeIntervalSince1970: Double(todo.scheduled) ) ).time)")
                    }
                }
            }  else if (searchKeyWord["dateTo"] != nil){
                let dateTo = unixFromDateString(date: searchKeyWord["dateTo"])
                
                resultArray = resultArray.filter({ $0.scheduled <= dateTo })
            }
    }
    
    // 検索内容の日付をUNIX型に変換
    func unixFromDateString(date dateString: Any) -> Int{
        let date = DateUtils.dateFromString(string: (dateString as! String), format: "yyyy年MM月dd日")
        return Int(date.timeIntervalSince1970)
    }
    
    // 完了/未完了切替処理
    func handleSwitchIsDone(indexPath: IndexPath){
        let updatedTimeUnix = Date().timeIntervalSince1970
        guard let todoId = self.resultArray[indexPath.row].todoId else {return}
        if self.resultArray[indexPath.row].isDone {
        
            TODOS_REF.child(todoId).child("isDone").setValue(false)
            TODOS_REF.child(todoId).child("updatedTime").setValue(updatedTimeUnix)
            self.resultArray[indexPath.row].isDone = false
        } else {
            
            TODOS_REF.child(todoId).child("isDone").setValue(true)
            TODOS_REF.child(todoId).child("updatedTime").setValue(updatedTimeUnix)
            self.resultArray[indexPath.row].isDone = true
        }
    }
    
    //iOS13以前でもナビバーを表示
    func makeNavbar(){
        if #available(iOS 13.0, *) {
        } else {
            let searchBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar-1")!, style: .plain, target: self, action: #selector(back))
            navigationItem.leftBarButtonItem = searchBarButtonItem
            
            Layout.segmentLayout(sortSegment)
            Layout.segmentLayout(isDoneSegment)
        }
    }
    
    // MARK: API
    func fetchFToDo(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        USER_TODOS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let todoId = snapshot.key
            
            TODOS_REF.child(todoId).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
                
                let todo = FToDo(todoId: todoId, dictionary: dictionary)
                print("todoArray: \(self.todoArray.count)件")
                // 編集ページからの遷移でなく、todoの数が元のtodoを上回らない
//                if self.dabCount == nil || self.todoArray.count < self.dabCount!{
                    self.todoArray.append(todo)
//                }
                self.tableView.reloadData()
            }
        }
    }

}
