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

//下線に色付け
extension FSCalendar {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

class ViewController: UIViewController,FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var myCalendar: FSCalendar!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isDoneCount: UILabel!
    
    var selectedIndexPath: NSIndexPath = NSIndexPath()
    let screenHeight = Int(UIScreen.main.bounds.size.height)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ToDo.makeSampleData(number: 400)
        tableView.delegate  = self
        tableView.dataSource = self
        self.myCalendar.dataSource = self
        self.myCalendar.delegate = self
        myCalendar.scrollDirection = .vertical
        
        let today = Date()
        let todayString = DateUtils.stringFromDate(date: today, format: "yyyy年MM月d日")
        selectedDateLabel.text = todayString
        doToDoCount()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myCalendar.reloadData()
        tableView.reloadData()
        doToDoCount()
        if let presented = self.presentedViewController {
            if type(of: presented) == ToDoDetailViewController.self {
                //詳細画面から戻ってきたときreload
                myCalendar.reloadData()
                tableView.reloadData()
            }
        }
    }
    
    //完了済件数の表示
    func doToDoCount(){
        var done:Int = 0
        var total:Int = 0
        let realm = try! Realm()
        let dateString = self.selectedDateLabel!.text
        let selectedDate = DateUtils.dateFromString(string: dateString!, format: "yyyy年MM月dd日")
        let predicate = NSPredicate(format: "%@ =< scheduledAt AND scheduledAt < %@", self.getBeginingAndEndOfDay(selectedDate).begining as CVarArg, self.getBeginingAndEndOfDay(selectedDate).end as CVarArg)
        let todos = realm.objects(ToDo.self).filter(predicate)
        for todo in todos{
            if todo.isDone { done += 1 }
        }
        total = todos.count
        if total > 0 {
            isDoneCount.text = "完了済　\(done)/ \(total)"
        } else {
            isDoneCount.text = ""
        }
        return
    }
    
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
        
       }
    
    @IBAction func addAction(_ sender: Any) {
        performSegue(withIdentifier: "goAddPage", sender: nil)
    }
    
    @IBAction func goListAction(_ sender: Any) {
        performSegue(withIdentifier: "goListPage", sender: nil)
    }
    //選択した日付を取得
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Void {
        
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        selectedDateLabel.text = "\(year)年\(month)月\(day)日"
        tableView.reloadData()
        doToDoCount()
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

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

    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }
        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
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
    
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        
        var maxPriority = 0
                let realm = try! Realm()
                var todos: Results<ToDo>!
                let predicate = NSPredicate(format: "%@ =< scheduledAt AND scheduledAt < %@", getBeginingAndEndOfDay(date).begining as CVarArg, getBeginingAndEndOfDay(date).end as CVarArg)
        todos = realm.objects(ToDo.self).filter(predicate).filter("isDone = false")
                if todos!.isEmpty{
                    return ""
                } else {
                    for todo in todos{
                        if todo.priority > maxPriority{
                           maxPriority = todo.priority
                        }
                    }
                }
        if maxPriority == 1{
            return "⭐️"
        } else if maxPriority == 2 {
            return "⭐️⭐️"
        } else {
            return "⭐️⭐️⭐️"
        }
    }
    
    //値の受け渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goAddPage" {
            let nextVC = segue.destination as! AddToDoViewController
            nextVC.selectedDateString = selectedDateLabel.text!
        } else if segue.identifier == "goDetailPage" {
            let nextVC = segue.destination as! ToDoDetailViewController
            nextVC.titleString = selectedDateLabel.text!
            let indexPath = self.selectedIndexPath
            let realm = try! Realm()
            let dateString = selectedDateLabel!.text
            let selectedDate = DateUtils.dateFromString(string: dateString!, format: "yyyy年MM月dd日")
            let predicate = NSPredicate(format: "%@ =< scheduledAt AND scheduledAt < %@", getBeginingAndEndOfDay(selectedDate).begining as CVarArg, getBeginingAndEndOfDay(selectedDate).end as CVarArg)
            let todos = realm.objects(ToDo.self).filter(predicate)
            nextVC.selectedDateString = dateString!
            nextVC.titleString = todos[indexPath.row].title
            nextVC.contentString = todos[indexPath.row].content
            nextVC.priority = todos[indexPath.row].priority
            nextVC.isDone = todos[indexPath.row].isDone
            if #available(iOS 13, *) {
            } else {
                nextVC.modalPresentationStyle = .pageSheet
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let dateString = selectedDateLabel!.text
        let selectedDate = DateUtils.dateFromString(string: dateString!, format: "yyyy年MM月dd日")
        let predicate = NSPredicate(format: "%@ =< scheduledAt AND scheduledAt < %@", getBeginingAndEndOfDay(selectedDate).begining as CVarArg, getBeginingAndEndOfDay(selectedDate).end as CVarArg)
        let todos = realm.objects(ToDo.self).filter(predicate)
        return todos.count
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
    //Cellの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = try! Realm()
        let dateString = selectedDateLabel!.text
        let selectedDate = DateUtils.dateFromString(string: dateString!, format: "yyyy年MM月dd日")
        let predicate = NSPredicate(format: "%@ =< scheduledAt AND scheduledAt < %@", getBeginingAndEndOfDay(selectedDate).begining as CVarArg, getBeginingAndEndOfDay(selectedDate).end as CVarArg)
        let todos = realm.objects(ToDo.self).filter(predicate)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if todos.count > indexPath.row {
            let todo = todos[indexPath.row]
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
    
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    // 完了/未完了処理
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let realm = try! Realm()
        let dateString = self.selectedDateLabel!.text
        let selectedDate = DateUtils.dateFromString(string: dateString!, format: "yyyy年MM月dd日")
        let predicate = NSPredicate(format: "%@ =< scheduledAt AND scheduledAt < %@", self.getBeginingAndEndOfDay(selectedDate).begining as CVarArg, self.getBeginingAndEndOfDay(selectedDate).end as CVarArg)
        let todos = realm.objects(ToDo.self).filter(predicate)
        let action = UITableViewRowAction(style: .normal, title: todos[indexPath.row].isDone ? "未完了" : "完了"){ action, indexPath in
            
            if todos[indexPath.row].isDone {
                try! realm.write {
                  todos[indexPath.row].isDone = false
                }
                self.doToDoCount()
                self.myCalendar.reloadData()
                tableView.reloadData()
            } else {
                try! realm.write {
                  todos[indexPath.row].isDone = true
                }
                self.doToDoCount()
                self.myCalendar.reloadData()
                tableView.reloadData()
            }
        }
        return [action]
    }
    
}

