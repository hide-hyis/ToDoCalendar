//
//  FToDo.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/05/19.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import Foundation

@objc class FToDo: NSObject{
    var todoId: String!
    var userId: String!
    @objc var title: String!
    @objc var content: String!
    var priority: Int!
    var categoryId: String!
    var scheduled: Int! // 予定日
    var imageURL: String!
    var isDone: Bool!
    var createdTime: Double! // 作成時間
    var updatedTime: Double! // 更新時間
    
    init(todoId: String!, dictionary: Dictionary<String, AnyObject>) {
        self.todoId = todoId
        
        if let title = dictionary["title"] as? String{
            self.title = title
        }
        
        if let content = dictionary["content"] as? String{
            self.content = content
        }
        
        if let userId = dictionary["userId"] as? String{
            self.userId = userId
        }
        
        if let scheduled = dictionary["schedule"] as? Int{
            self.scheduled = scheduled
        }
        
        if let isDone = dictionary["isDone"] as? Bool{
            self.isDone = isDone
        }
        
        if let priority = dictionary["priority"] as? Int{
            self.priority = priority
        }
        
        if let dateAt = dictionary["createdTime"] as? Double{
            self.createdTime = dateAt
        }
        
        if let updatedTime = dictionary["updatedTime"] as? Double{
            self.updatedTime = updatedTime
        }
    }
    
    
}
