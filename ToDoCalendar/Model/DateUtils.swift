//
//  DateUtils.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/01/29.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class DateUtils:Object {
    @objc dynamic var month: Int
    
    required init() {
        month = Calendar.current.component(.month, from: Date()) //今月を登録
    }
    
    //StringからDate型に変換
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.date(from: string)!
    }
    
    //DateからString型に変換
    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    class func pickerConfig( _ datePicker: UIDatePicker, _ dateField: UITextField){
        // ピッカー設定
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        dateField.inputView = datePicker
    }
    
    class func createTimestamp() -> String{
        let timeInterval = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timeInterval)
        let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let timestamp = formatter.string(from: time as Date)
        return timestamp
    }
    
    
}
