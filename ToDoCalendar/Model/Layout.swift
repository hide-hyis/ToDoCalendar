//
//  Layout.swift
//  ToDoCalendar
//
//  Created by 石井秀泰 on 2020/02/08.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import Foundation
import RealmSwift

class Layout: Object {
    
    class func textViewOutLine ( _ contentTextField: UITextView){
        contentTextField.layer.borderWidth = 1.0
        contentTextField.layer.borderColor = UIColor.gray.cgColor
        contentTextField.layer.cornerRadius = 1.0
    }
    
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
    
    
    class func starZero(_ star:UIButton, _ star2:UIButton, _ star3:UIButton){
        star.setTitleColor(UIColor.gray, for: .normal)
        star2.setTitleColor(UIColor.gray, for: .normal)
        star3.setTitleColor(UIColor.gray, for: .normal)
    }
    
    class func buttonBorderRadius(buttono:UIButton, width: CGFloat, radius:CGFloat){
        buttono.layer.borderWidth = width
        buttono.layer.cornerRadius = radius
    }
    
    class func listTableCellFont(cell: UITableViewCell) {
        if Int(UIScreen.main.bounds.size.height) <= 736 {
            cell.textLabel!.font = UIFont(name: "Arial", size: 15)
            cell.detailTextLabel!.font = UIFont(name: "Arial", size: 15)
        } else {
            cell.textLabel!.font = UIFont(name: "Arial", size: 18)
            cell.detailTextLabel!.font = UIFont(name: "Arial", size: 18)
        }
        
    }
    
    class func calendarTableCellFont(cell: UITableViewCell) {
        if Int(UIScreen.main.bounds.size.height) <= 736 {
            cell.textLabel!.font = UIFont(name: "Arial", size: 17)
            cell.detailTextLabel!.font = UIFont(name: "Arial", size: 15)
        } else {
            cell.textLabel!.font = UIFont(name: "Arial", size: 18)
            cell.detailTextLabel!.font = UIFont(name: "Arial", size: 18)
        }
        
    }
}
