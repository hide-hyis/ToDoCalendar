//
//  Category.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/06/03.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import Foundation

class Category {
    
    var name: String!
    var createdTime: Double!
    var updatedTime: Double!
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let name = dictionary["name"] as? String{
            self.name = name
        }
        
        if let createdTime = dictionary["createdTime"] as? Double{
            self.createdTime = createdTime
        }
        
        if let updatedTime = dictionary["updatedTime"] as? Double{
            self.updatedTime = updatedTime
        }
    }
}
