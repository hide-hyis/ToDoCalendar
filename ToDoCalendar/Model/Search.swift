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
    @objc dynamic var sort: String  = "dateAt"//検索ソートの切替フラグ
    @objc dynamic var asc: Bool  = true//昇順・降順の切替フラグ
    @objc dynamic var isDone: Bool  = false//完了/未完の切替フラグ
    
//    class func sortInstance(){
//        let realm = try! Realm()
//        return sort = realm.objects(Search.self).first!.sort
//
//    }
}
