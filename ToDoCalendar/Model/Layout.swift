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
            cell.textLabel!.font = UIFont(name: "Arial", size: 16)
            cell.detailTextLabel!.font = UIFont(name: "Arial", size: 16)
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

    //擬似ナビバー
    class func blankView(_ uiViewController: UIViewController){
        let blankView = UIView()
        let screenSize: CGSize = UIScreen.main.bounds.size
        blankView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 75)
        blankView.backgroundColor = UIColor(red: 247/255, green: 246/255, blue: 246/255, alpha: 1)
        uiViewController.view.addSubview(blankView)
    }
    
//    class func navBarBack(_ uiViewController: UIViewController) {
//        let backButton  = UIButton()
//        backButton.frame = CGRect(x: 20, y: 60, width: 20, height: 20)
//        backButton.setImage(UIImage(named: "calendar-1"), for: .normal)
//        backButton.setTitleColor(UIColor.blue, for: .normal)
//        backButton.addTarget(self, action: #selector(prePage()), for: UIControl.Event.touchUpInside)
//        uiViewController.view.addSubview(backButton)
//        uiViewController.view.bringSubviewToFront(backButton)
//    }
//    class func navBarDelete(_ uiViewController: UIViewController){
//        let deleteButton  = UIButton()
//        deleteButton.frame = CGRect(x: 330, y: 60, width: 20, height: 20)
//        deleteButton.setImage(UIImage(named: "delete"), for: .normal)
//        deleteButton.setTitleColor(UIColor(red: 34/255, green: 134/255, blue: 247/255, alpha: 1), for: .normal)
//        deleteButton.addTarget(self, action: #selector(ToDoDetailViewController.deleteAction), for: UIControl.Event.touchUpInside)
//        uiViewController.view.addSubview(deleteButton)
//        uiViewController.view.bringSubviewToFront(deleteButton)
//    }
    //ナビバータイトル表示
    class func navBarTitle(_ uiViewController: UIViewController, _ title:String){
        let toDoLabel  = UILabel()
        toDoLabel.frame = CGRect(x:50,y:25,width: 70,height:70)
        toDoLabel.textAlignment = .center
        toDoLabel.center.x = uiViewController.view.center.x
        toDoLabel.textAlignment = NSTextAlignment.center
        toDoLabel.text = title
        toDoLabel.font = UIFont.systemFont(ofSize: 16)
        toDoLabel.textColor = UIColor.black
        toDoLabel.font = UIFont.boldSystemFont(ofSize: 17)
        uiViewController.view.addSubview(toDoLabel)
        uiViewController.view.bringSubviewToFront(toDoLabel)
    }
    
    class func segmentLayout( _ segment: UISegmentedControl){
        segment.layer.borderWidth = 1
        segment.layer.borderColor = UIColor.gray.cgColor
        segment.clipsToBounds = true
        segment.layer.cornerRadius = 8
        segment.tintColor = UIColor.white
        segment.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 238/255, alpha: 1)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "HiraKakuProN-W6", size: 12.0)!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ], for: .selected)
    }
}
