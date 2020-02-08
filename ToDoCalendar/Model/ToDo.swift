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
    
    class func star1Button(_ star:UIButton, _ star2:UIButton, _ star3:UIButton){
        star.setTitleColor(UIColor.black, for: .normal)
        star2.setTitleColor(UIColor.gray, for: .normal)
        star3.setTitleColor(UIColor.gray, for: .normal)
    }
    class func star2Button(_ star:UIButton, _ star2:UIButton, _ star3:UIButton){
        star.setTitleColor(UIColor.black, for: .normal)
        star2.setTitleColor(UIColor.black, for: .normal)
        star3.setTitleColor(UIColor.gray, for: .normal)
    }
    class func star3Button(_ star:UIButton, _ star2:UIButton, _ star3:UIButton){
        star.setTitleColor(UIColor.black, for: .normal)
        star2.setTitleColor(UIColor.black, for: .normal)
        star3.setTitleColor(UIColor.black, for: .normal)
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
    
//    class func stringPriority( _ todo:Object) -> Void{
//        switch todo.priority {
//        case 1:
//             "★"
//        case 2:
//             "★★"
//        case 3:
//             "★★★"
//        default:
//            ""
//        }
//    }
}
