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
    
    
}
