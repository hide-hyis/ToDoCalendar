//
//  User.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/05/15.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    var uid:String
    var isLogin = false
    
    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        
        self.uid = uid
        
        if let isLogin = dictionary["isLogin"] as? Bool {
            self.isLogin = isLogin
        }
    }
}
