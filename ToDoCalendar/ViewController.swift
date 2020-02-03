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
    
    let fruits = ["apple", "orange", "melon", "banana", "pineapple","tomatos","water melon","beets","spinatch","mangoo"]
    let detailFruits = ["リンゴ", "オレンジ", "メロン", "バナナ", "パイナップル","トマト","スイカ","ビーツ","ほうれん草","マンゴー"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.myCalendar.dataSource = self
        self.myCalendar.delegate = self
        myCalendar.scrollDirection = .vertical
        
        let today = Date()
        let todayString = DateUtils.stringFromDate(date: today, format: "yyyy年MM月d日")
        selectedDateLabel.text = todayString
        myCalendar.addBorderBottom(height: 1.0, color: UIColor.black)
        
//        let realm = try! Realm()
//        let todos = realm.objects(ToDo.self)
//        print("カウント\(todos.count)")
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        myCalendar.reloadData()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
        
       }
    
    @IBAction func addAction(_ sender: Any) {
        performSegue(withIdentifier: "goAddPage", sender: nil)
    }
    
    
    
    //選択した日付を取得
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Void {
        
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        selectedDateLabel.text = "\(year)年\(month)月\(day)日"
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
                todos = realm.objects(ToDo.self).filter(predicate)
                if todos!.isEmpty{
                    return ""
                } else {
                    for i in todos{
                        if i.priority > maxPriority{
                           maxPriority = i.priority
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goAddPage" {
            let nextVC = segue.destination as! AddToDoViewController
            nextVC.selectedDateString = selectedDateLabel.text!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let todos = realm.objects(ToDo.self)
        return todos.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = try! Realm()
        let todos = realm.objects(ToDo.self)
        let todo = todos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = todo.title
//        cell.detailTextLabel?.text = "優先度表示"
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
        return cell
    }
}

