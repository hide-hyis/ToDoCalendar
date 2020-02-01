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
}
