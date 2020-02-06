//
//  ToDoListViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/02/06.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    
    @IBOutlet weak var detailTextView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        tableView.delegate = self
        tableView.dataSource = self
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.cornerRadius = 20.0
        detailTextView.layer.borderColor = UIColor.black.cgColor
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let realm = try! Realm()
        let todos = realm.objects(ToDo.self)
        return todos.count
    }
    
    //セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = try! Realm()
        let todos = realm.objects(ToDo.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let todo = todos[indexPath.row]
        let date = DateUtils.stringFromDate(date: todo.scheduledAt, format: "MM/dd")
        if todo.title.count >= 11 {
            let longTitle = todo.title.prefix(10)
            cell.textLabel!.text = longTitle + "..."
        } else {
            cell.textLabel!.text = todo.title
        }
        switch todo.priority {
        case 1:
            cell.detailTextLabel?.text = "\(date)           ★"
        case 2:
            cell.detailTextLabel?.text = "\(date)       ★★"
        case 3:
            cell.detailTextLabel?.text = "\(date)   ★★★"
        default:
            cell.detailTextLabel?.text = ""
        }
        if todo.isDone == true{
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        } else {
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        }
        return cell
    }
    
    //セルクリックで詳細表示
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
    
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    // 完了/未完了処理
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let realm = try! Realm()
        let todos = realm.objects(ToDo.self)
        let action = UITableViewRowAction(style: .normal, title: todos[indexPath.row].isDone ? "未完了" : "完了"){ action, indexPath in
            
            if todos[indexPath.row].isDone {
                try! realm.write {
                  todos[indexPath.row].isDone = false
                }
            } else {
                try! realm.write {
                  todos[indexPath.row].isDone = true
                }
            }
            tableView.reloadData()
        }
        return [action]
    }
}
