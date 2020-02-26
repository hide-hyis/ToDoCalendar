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
    
    
    class func createDefault( _ realm: Realm){
        if realm.objects(Search.self).count == 0 {
            let search1 = Search()
            try! realm.write {
              realm.add(search1) //デフォルト値の作成
            }
        }

        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    class func getSearchProperties( _ realm: Realm) -> (String, Bool, String, Results<ToDo>){
        let sortInstance = realm.objects(Search.self).last
        let sort = sortInstance?.sort
        let asc = sortInstance?.asc
        let isDone = sortInstance?.isDone
        let isDoneString : String = String(isDone!)
        var todos = realm.objects(ToDo.self).sorted(byKeyPath: "\(sort!)", ascending: asc!).filter("isDone == \(isDoneString)")
        return (sort!, asc!, isDoneString, todos)
    }
    
    
}
