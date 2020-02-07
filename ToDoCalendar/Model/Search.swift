//
//  Search.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/02/07.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import Foundation
import RealmSwift

class Search: Object {
    @objc dynamic var sort: String  = ""
    @objc dynamic var asc: Bool  = true
//    class func sortInstance(){
//        let realm = try! Realm()
//        return sort = realm.objects(Search.self).first!.sort
//
//    }
}
