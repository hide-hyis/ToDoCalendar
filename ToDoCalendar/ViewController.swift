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

class ViewController: UIViewController,FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance {

    @IBOutlet weak var myCalendar: FSCalendar!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myCalendar.dataSource = self
        self.myCalendar.delegate = self
        myCalendar.scrollDirection = .vertical
        
        let today = Date()
        let todayString = DateUtils.stringFromDate(date: today, format: "yyyy年MM月d日")
        selectedDateLabel.text = todayString
        myCalendar.addBorderBottom(height: 1.0, color: UIColor.black)
        
        
//        let realm = try! Realm()
//        var todos: Results<ToDo>!
//
//        let predicate = NSPredicate(format: "%@ =< scheduledAt AND scheduledAt < %@", getBeginingAndEndOfDay(20200131).begining as CVarArg, getBeginingAndEndOfDay(20200131).end as CVarArg)
//        let tmpCalendar = Calendar(identifier: .gregorian)
//        todos = realm.objects(ToDo.self).filter(predicate)
//        var maxPriority = 0
//        for i in 0...todos.count{
//            if maxPriority < todos[i].priority {
//                maxPriority = todos[i].priority
//            }
//        }
//        print("maxPriority:\(maxPriority)")
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

    
    //日付に星をつける関数
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int{

        let realm = try! Realm()
        var todos: Results<ToDo>!
        let predicate = NSPredicate(format: "%@ =< scheduledAt AND scheduledAt < %@", getBeginingAndEndOfDay(date).begining as CVarArg, getBeginingAndEndOfDay(date).end as CVarArg)
        let tmpCalendar = Calendar(identifier: .gregorian)
        todos = realm.objects(ToDo.self).filter(predicate)
        var maxPriority = 0
        
        for i in todos{
            if i.priority > maxPriority{
               maxPriority = i.priority
            }
        }
        print("maxPriority: \(maxPriority)")
        return todos.count
        // 予定日に反映->OK
        //予定日の最大優先度をfilterなし算出->OK
        //予定日の最大優先度を日付filterベタ打ち算出->途中
        //予定日の最大優先度を算出->途中
//        print("maxPriority:\(maxPriority)")
//        return todos!.count
//        日にちの年、月、日を取得
//        let day = tmpCalendar.component(.day, from: date)
//
//        if day == 5 {
//            return "★"
//        }else{
//            return ""
//        }
    }
    // 日の始まりと終わりを取得
    private func getBeginingAndEndOfDay(_ date:Date) -> (begining: Date , end: Date) {
        let begining = Calendar(identifier: .gregorian).startOfDay(for: date)
        let end = begining + 24*60*60
        return (begining, end)
    }

    //最大priprityを返す関数　引数は選択日date
//    func maxPriority(date: Date) {
//        let realm = try! Realm()
//        let todos = realm.objects(ToDo.self)
//        let selectedToDo = realm.objects(ToDo.self).filter("scheduledAt = date")
//        print(selectedToDo)
//        return 1
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goAddPage" {
            let nextVC = segue.destination as! AddToDoViewController
            nextVC.selectedDateString = selectedDateLabel.text!
        }
    }
}

