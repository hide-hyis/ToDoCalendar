//
//  DateUtils.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/01/29.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import Foundation
import UIKit

class DateUtils {
    
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
        datePicker.locale = Locale.current
        dateField.inputView = datePicker
    }
    
}
