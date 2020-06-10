//
//  RootViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/05/28.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import Firebase

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        if Auth.auth().currentUser != nil {
            let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            calendarVC.fromLogin = false
            self.navigationController?.pushViewController(calendarVC, animated: true)
        }else{
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginViewController, animated: true)
        }
    }

    
}
