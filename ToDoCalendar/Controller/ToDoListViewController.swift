
//  ToDoListViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/02/06.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class ToDoListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, CatchProtocol, DetailProtocol {
    
    
    
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
    
    var titleKey: String?
    var contentKey: String?
    var dateFromKey: Date?
    var dateToKey: Date?
    var priority: Int?
    var predicates: [NSPredicate] = []
    var compoundedPredicate: NSCompoundPredicate?
    var segmentIndex:Int = 0
    var isDoneSegmentIndex:Int = 0
    let screenHeight = Int(UIScreen.main.bounds.size.height)
    var todoArray = [FToDo]()               // ユーザーが持つtodo全件
    var resultArray = [FToDo]()             // filter後のtodo全件
    var selectedDateTodoArray = [FToDo]()   // 重複しない選択日のToDo配列
    var todo:FToDo?                         //タップされたtodo項目
    var segmentCheck = false               // 未完/完了タブの切替
    var asc = true                         // 逆順フラグ
    var selectedIndexPath: NSIndexPath = NSIndexPath()
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFToDo()
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
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
        
        //iOS13以前でもナビバーを表示
        if #available(iOS 13.0, *) {
        } else {
            let searchBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar-1")!, style: .plain, target: self, action: #selector(back))
            navigationItem.leftBarButtonItem = searchBarButtonItem
            
            Layout.segmentLayout(sortSegment)
            Layout.segmentLayout(isDoneSegment)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    //検索ワードの受取
    func catchData(key: [String : String]) {
        predicates.removeAll() //検索内容の初期化
        if key["title"] != nil { predicates.append(NSPredicate(format: "title CONTAINS[c] %@", key["title"]!)) }
        if key["content"] != nil { predicates.append(NSPredicate(format: "content CONTAINS[c] %@", key["content"]!)) }
        if key["dateFrom"] != nil { dateFromKey = DateUtils.dateFromString(string: key["dateFrom"]!, format: "yyyy年MM月dd日")} //dateFromを文字型から日付型に変換
        if key["dateTo"] != nil { dateToKey = DateUtils.dateFromString(string: key["dateTo"]!, format: "yyyy年MM月dd日")} //dateToを文字型から日付型に変換
        if dateFromKey != nil && dateToKey != nil {
            predicates.append(NSPredicate(format:"scheduledAt >= %@ AND scheduledAt <= %@", dateFromKey! as CVarArg, dateToKey! as CVarArg))
        } else if dateToKey != nil {
            predicates.append(NSPredicate(format:"scheduledAt <= %@", dateToKey! as CVarArg))
        } else if dateFromKey != nil {
            predicates.append(NSPredicate(format:"scheduledAt >= %@", dateFromKey! as CVarArg))
        }
        if key["priority"] != nil { priority = Int(key["priority"]!)! }
        if priority != nil { predicates.append(NSPredicate(format: "priority == %i", priority!)) }
        compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        print("検索条件\(key)")
        tableView.reloadData()
        titleLabel.text = "タイトル"
        contentLabel.text = "内容"
        dateLabel.text = "予定日"
        priorityLabel.text = "★"
    }
    
    
    // MARK: EVENT ACTION
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //ソートの切替
    @IBAction func segmentAction(_ sender: Any) {
        let search = realm.objects(Search.self).first
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            try! realm.write {search!.sort = "dateAt"}
            UserDefaults.standard.set(" ", forKey: "sortKey")
            tableView.reloadData()
        case 1:
            try! realm.write {search!.sort = "scheduledAt"}
            UserDefaults.standard.set("schedule", forKey: "sortKey")
            tableView.reloadData()
        case 2:
            try! realm.write {search!.sort = "priority"}
            UserDefaults.standard.set("priority", forKey: "sortKey")
            tableView.reloadData()
        default:
            return
        }
    }
    
//    未完/完了セグメント切替処理
    @IBAction func switchIsDone(_ sender: Any) {
        let search = realm.objects(Search.self).last
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(false, forKey: "segmentCheck")
            try! realm.write {
                search!.isDone = false
            }
            tableView.reloadData()
        case 1:
            UserDefaults.standard.set(true, forKey: "segmentCheck")
            try! realm.write {
                search!.isDone = true
            }
            tableView.reloadData()
        default:
            return
        }
    }
    
    //逆順切替
    @IBAction func sortRev(_ sender: Any) {
        /* Realm DB
        let search = realm.objects(Search.self).last
        if search!.asc {
            try! realm.write {
            search!.asc = false
            }
        } else {
            try! realm.write {
                search!.asc = true
            }
        }
        */
        
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
            /*
            let realm = try! Realm()
            let todo = realm.objects(ToDo.self).filter(" title == %@", titleLabel.text!).first
            let dateString = DateUtils.stringFromDate(date: todo!.scheduledAt, format: "yyyy年MM月dd日")
            nextVC.titleString = titleLabel.text!
            nextVC.titleString = todo!.title
            nextVC.contentString = todo!.content
            nextVC.priority = todo!.priority
            nextVC.isDone = todo!.isDone
            */
            let dateComponentsArray = dateLabel!.text!.components(separatedBy: "/")
            let datestr = "\(dateComponentsArray[0])年\(dateComponentsArray[1])月\(dateComponentsArray[2])日"
            nextVC.todo = self.todo
            nextVC.selectedDateString = datestr
            nextVC.delegate = self
        }else if segue.identifier == "goSearchPage" {
            let nextVC = segue.destination as! SearchViewController
            nextVC.delegate = self
        }
    }
    
    //検索内容を空にするクリアボタン
    @IBAction func clearAction(_ sender: Any) {
        if compoundedPredicate != nil {
            predicates = []
            compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                return tableView.layer.bounds.height/5
    }
    
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*  Realm DB
        Search.createDefault(realm)
        var search = Search.getSearchProperties(realm)
        if compoundedPredicate != nil {
            search.3 = realm.objects(ToDo.self).sorted(byKeyPath: "\(search.0)", ascending: search.1).filter(compoundedPredicate!).filter("isDone == \(search.2)")
        }
        return search.3.count
        */
        
        makeResultArray()
        return resultArray.count
    }
    
    //セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        /*  Realm DB
        Search.createDefault(realm)
        var search = Search.getSearchProperties(realm)
        if compoundedPredicate != nil {
            search.3 = realm.objects(ToDo.self).sorted(byKeyPath: "\(search.0)", ascending: search.1).filter(compoundedPredicate!).filter("isDone == \(search.2)")
        }
        let todo = search.3[indexPath.row]
        let date = DateUtils.stringFromDate(date: todo.scheduledAt, format: "YYYY/MM/dd")

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
        */
        
        todoArrayForCell(cell: cell, indexPath: indexPath)
        
        Layout.listTableCellFont(cell: cell)
        return cell
    }
    //セルクリックで下部詳細表示
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        /*　　Realm DB
        var search = Search.getSearchProperties(realm)//Searchプロパティとtodosの取得
        if compoundedPredicate != nil {
            search.3 = realm.objects(ToDo.self).sorted(byKeyPath: "\(search.0)", ascending: search.1).filter(compoundedPredicate!).filter("isDone == \(search.2)")
        }
         let todo = search.3[indexPath.row]
         */
        
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
//        Search.createDefault(realm)
//        var search = Search.getSearchProperties(realm)
//        if compoundedPredicate != nil {
//            search.3 = realm.objects(ToDo.self).sorted(byKeyPath: "\(search.0)", ascending: search.1).filter(compoundedPredicate!).filter("isDone == \(search.2)")
//        }
//        let action = UIContextualAction(style: .normal,
//                                        title: search.3[indexPath.row].isDone ? "未完了" : "完了") { (action, view, completionHandler) in
//              // 処理を実行
//                if search.3[indexPath.row].isDone {
//                                try! realm.write {
//                                  search.3[indexPath.row].isDone = false
//                                }
//                            } else {
//                                try! realm.write {
//                                  search.3[indexPath.row].isDone = true
//                                }
//                            }
//                            tableView.reloadData()
//              completionHandler(true)
//        }
        
        makeResultArray()
        
        let action = UIContextualAction(style: .normal,
                                        title: resultArray[indexPath.row].isDone ? "未完了" : "完了") { (action, view, completionHandler) in
                                            
              // 完了切替処理を実行(Firebase)
              self.handleSwitchIsDone(indexPath: indexPath)
             
              tableView.reloadData()
              completionHandler(true)
        }
        
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    // MARK: - Handler
    
    func configureSegment(){
        let search = realm.objects(Search.self).first
        //sortセグメントの初期表示
        switch  search?.sort{
        case "dateAt":
            segmentIndex = 0
        case "scheduledAt":
            segmentIndex = 1
        case "priority":
            segmentIndex = 2
        default:
            segmentIndex = 0
        }
        sortSegment.selectedSegmentIndex = segmentIndex
        
        //未完,完了セグメントの初期表示
        switch search?.isDone {
        case false:
            isDoneSegmentIndex = 0
        case true:
            isDoneSegmentIndex = 1
        default:
            isDoneSegmentIndex = 0
        }
        isDoneSegment.selectedSegmentIndex = isDoneSegmentIndex
    }
    

    // TableView表示のcellをFirebaseのデータから当てはめる
    func todoArrayForCell(cell: UITableViewCell, indexPath: IndexPath){
        makeResultArray()
        if resultArray.isEmpty {return}
        
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
        
        segmentCheck = UserDefaults.standard.bool(forKey: "segmentCheck")
        resultArray = todoArray.filter({$0.isDone == segmentCheck})
        // 表示のソート
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
    
    // 完了/未完了切替処理
    func handleSwitchIsDone(indexPath: IndexPath){
        guard let todoId = self.resultArray[indexPath.row].todoId else {return}
        if self.resultArray[indexPath.row].isDone {
        
            TODOS_REF.child(todoId).child("isDone").setValue(false)
            self.resultArray[indexPath.row].isDone = false
        } else {
            
            TODOS_REF.child(todoId).child("isDone").setValue(true)
            self.resultArray[indexPath.row].isDone = true
        }
    }
    
    
    
    // MARK: API
    func fetchFToDo(){
        USER_TODOS_REF.child("user1").observe(.childAdded) { (snapshot) in
            let todoId = snapshot.key
            
            TODOS_REF.child(todoId).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
                
                let todo = FToDo(todoId: todoId, dictionary: dictionary)
                self.todoArray.append(todo)
                self.tableView.reloadData()
            }
        }
    }
}
