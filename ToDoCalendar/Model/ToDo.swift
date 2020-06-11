//
//  ToDo.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/01/28.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class ToDo: Object {
    @objc dynamic var title: String  = ""
    @objc dynamic var content: String  = ""
    @objc dynamic var priority: Int = 0
    @objc dynamic var scheduledAt = Date()
    @objc dynamic var dateAt: Date = NSDate() as Date
    @objc dynamic var isDone: Bool = false
    
    var todoId: String!
    var userId: String!
    var categoryId: String!
    var schedule: Int! // 予定日
    var imageURL: String!
    var createdTime: Double! // 作成時間
    var updatedTime: String! // 更新時間
    
    init(todoId: String!, dictionary: Dictionary<String, AnyObject>) {
        self.todoId = todoId
        
        if let title = dictionary["title"] as? String{
            self.title = title
        }
        
        if let content = dictionary["content"] as? String{
            self.content = content
        }
        
        if let userId = dictionary["userId"] as? String{
            self.userId = userId
        }
        
        if let schedule = dictionary["schedule"] as? Int{
            self.schedule = schedule
        }
        
        if let isDone = dictionary["isDone"] as? Bool{
            self.isDone = isDone
        }
        
        if let priority = dictionary["priority"] as? Int{
            self.priority = priority
        }
        
        if let dateAt = dictionary["dateAt"] as? Double{
            self.createdTime = dateAt
        }
        
        if let updatedTime = dictionary["updatedTime"] as? String{
            self.updatedTime = updatedTime
        }
    }
    
    override required init() {
//        fatalError("init() has not been implemented")
    }
    
    class func isDoneDisplay( _ isDone:Bool, _ isDoneSegment:UISegmentedControl){
        if isDone {
            isDoneSegment.selectedSegmentIndex = 1
        } else {
            isDoneSegment.selectedSegmentIndex = 0
        }
    }
    
    class func invalidButton( _ button:UIButton){
        button.isEnabled = false
        button.setTitleColor(.gray, for: .disabled)
    }
    
    class func validButton( _ button:UIButton){
        button.isEnabled = true
        button.setTitleColor(.white, for: .normal)
    }
    
    //textField入力値制限アラート
    class func textFieldAlert(_ textField: UITextField, _ button: UIButton, _ num: Int) {
        let limitedNum = num
        let str = textField.text!
        if textField.text! == "" {
            invalidButton(button)
        }else {
            if textField.text!.count > num {
                let extraStr = str.count - limitedNum
                let attrText = NSMutableAttributedString(string: str)
                attrText.addAttributes([
                    .foregroundColor: UIColor.gray,
                    .backgroundColor: UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 0.5)
                    ], range: NSRange(location:num, length:extraStr)
                )
                textField.attributedText = attrText
                invalidButton(button)
            }else if textField.text!.count <= num {
                let attrText = NSMutableAttributedString(string: str)
                attrText.addAttributes([
                    .foregroundColor: UIColor.black,
                    .backgroundColor: UIColor.white
                    ], range: NSRange(location:0, length:textField.text!.count)
                )
                textField.attributedText = attrText
                validButton(button)
            }
        }
    }
    
    //textView入力値制限アラート
    class func textViewdAlert(_ textView: UITextView, _ button: UIButton, _ num: Int) {
        let limitedNum = num
        if textView.text!.count > num {
            let str = textView.text!
            let attrText = NSMutableAttributedString(string: str)
            attrText.addAttributes([
                .foregroundColor: UIColor.gray,
                .backgroundColor: UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 0.5)
            ], range: NSMakeRange(limitedNum, str.count - limitedNum)
            )
            textView.attributedText = attrText
            invalidButton(button)
        }else {
            validButton(button)
        }
    }
    
    
    // 文字列変換yy年mm月dd日 -> yy/mm/dd
    class func dateStringTodae(string: String) -> (String,String,String){
        let moji = string
        let yyyy = String(moji[moji.index(moji.startIndex, offsetBy: 0)..<moji.index(moji.startIndex, offsetBy: 4)])
        let mm = String(moji[moji.index(moji.startIndex, offsetBy: 5)..<moji.index(moji.startIndex, offsetBy: 7)])
        let dd = String(moji[moji.index(moji.startIndex, offsetBy: 8)..<moji.index(moji.startIndex, offsetBy: 10)])
        return (yyyy, mm, dd)
    }
    
    //サンプルデータを引数の数だけ作る
    class func makeSampleData(number:Int){
        let realm = try! Realm()
        let todosCount = realm.objects(ToDo.self).count
        if todosCount < number {
            for i in 21...number{
                var randMon = String(randomNum(lower: 1, upper: 13))
                var randDay = String(randomNum(lower: 1, upper: 30))
                let todoi = ToDo()
                todoi.title = "titleNo.\(i)"
                todoi.content = "contentNo.\(i)"
                todoi.priority = Int(randomNum(lower: 1, upper: 4))
                todoi.scheduledAt = DateUtils.dateFromString(string: "2020年\(randMon)月\(randDay)日", format: "yyyy年MM月dd日")
                todoi.dateAt = DateUtils.dateFromString(string: "2020年\(randMon)月\(randDay)日", format: "yyyy年MM月dd日")
                try! realm.write{
                    realm.add(todoi)
                }
            }
        }

    }
    
    //ランダムな整数を返す
    class func randomNum(lower: UInt32, upper: UInt32) -> UInt32 {
        guard upper >= lower else {
            return 0
        }
        return arc4random_uniform(upper - lower) + lower
    }
}


