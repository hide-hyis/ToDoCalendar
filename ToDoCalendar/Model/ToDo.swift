//
//  ToDo.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/01/28.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import Foundation
import RealmSwift

class ToDo: Object {
    @objc dynamic var title: String  = ""
    @objc dynamic var content: String  = ""
    @objc dynamic var priority: Int = 0
    @objc dynamic var scheduledAt = Date()
    @objc dynamic var dateAt: Date = NSDate() as Date
    @objc dynamic var isDone: Bool = false
    
    
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
        button.setTitleColor(.black, for: .normal)
    }
    
    //textField入力値制限アラート
    class func textFieldAlert(_ textField: UITextField, _ button: UIButton, _ num: Int) {
        let limitedNum = num
        if textField.text! == "" {
            invalidButton(button)
        }else {
            if textField.text!.count > num {
                let str = textField.text!
                let attrText = NSMutableAttributedString(string: str)
                attrText.addAttributes([
                    .foregroundColor: UIColor.gray,
                    .backgroundColor: UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 0.5)
                ], range: NSMakeRange(limitedNum, str.count - limitedNum)
                )
                textField.attributedText = attrText
                invalidButton(button)
            }else {
                validButton(button)
            }
        }
    }
    
    //textView入力値制限アラート
    class func textViewdAlert(_ textView: UITextView, _ button: UIButton, _ num: Int) {
        let limitedNum = num
        if textView.text! == "" {
            invalidButton(button)
        }else {
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
    }
    
    // 文字列変換yy年mm月dd日 -> yy/mm/dd
    class func dateStringTodae(string: String) -> (String,String,String){
        let moji = string
        let yyyy = String(moji[moji.index(moji.startIndex, offsetBy: 0)..<moji.index(moji.startIndex, offsetBy: 4)])
        let mm = String(moji[moji.index(moji.startIndex, offsetBy: 5)..<moji.index(moji.startIndex, offsetBy: 7)])
        let dd = String(moji[moji.index(moji.startIndex, offsetBy: 8)..<moji.index(moji.startIndex, offsetBy: 10)])
        return (yyyy, mm, dd)
    }
    
}


