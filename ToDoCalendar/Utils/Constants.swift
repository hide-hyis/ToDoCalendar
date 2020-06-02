//
//  Constants.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/05/15.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import RealmSwift
import Firebase

// MARK: root Firebase
let DB_REF = Database.database().reference()
let STORE_REF = Storage.storage().reference()

// MARK: Database Reference
let USER_REF = DB_REF.child("users")
let USER_TODOS_REF = DB_REF.child("user-todos")

let TODOS_REF = DB_REF.child("todos")
let CALENDAR_TODOS_REF = DB_REF.child("calendar-todos")
let CATEGORIES_REF = DB_REF.child("categories")

let STORAGE_TODO_IMAGES_REF = STORE_REF.child("todo_images")

let realm = try! Realm()
