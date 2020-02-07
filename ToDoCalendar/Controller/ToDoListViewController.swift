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
    @IBOutlet weak var sortSegment: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        tableView.delegate = self
        tableView.dataSource = self
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.cornerRadius = 20.0
        detailTextView.layer.borderColor = UIColor.black.cgColor
        swipeGesture.isEnabled = false
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
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
    
    //ソートの切替---->searh.sortを追加していくのではなくて更新してくように変更
    @IBAction func segmentAction(_ sender: Any) {
        let realm = try! Realm()
        let search = Search()
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            search.sort = "dateAt"
            try! realm.write {
              realm.add(search)
            }
            tableView.reloadData()
        case 1:
            search.sort = "scheduledAt"
            try! realm.write {
              realm.add(search)
            }
            tableView.reloadData()
        case 2:
            search.sort = "priority"
            try! realm.write {
              realm.add(search)
            }
            tableView.reloadData()
        default:
            return
        }
    }
    
    @IBAction func sortRev(_ sender: Any) {
        let realm = try! Realm()
//        let search = Search()
        let search = realm.objects(Search.self).last
        if search!.asc {
            try! realm.write {
            search!.asc = false
            }
        } else {
            try! realm.write {
                search!.asc = true
            }
        }
        tableView.reloadData()
    }
    
    //セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = try! Realm()
        let sortInstance = realm.objects(Search.self).last
        let sort = sortInstance?.sort
        let todos = realm.objects(ToDo.self).sorted(byKeyPath: "\(sort!)")
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
        
        let realm = try! Realm()
        let todos = realm.objects(ToDo.self)
        let todo = todos[indexPath.row]
        titleLabel.text = todo.title
        contentLabel.text = todo.content
        dateLabel.text = DateUtils.stringFromDate(date: todo.scheduledAt, format: "MM/dd")
        switch todo.priority {
        case 1:
            priorityLabel.text = "★"
        case 2:
            priorityLabel.text = "★★"
        case 3:
            priorityLabel.text = "★★★"
        default:
            priorityLabel.text = ""
        }
        if todo.isDone == true {
            titleLabel.textColor = UIColor.gray; contentLabel.textColor = UIColor.gray
            dateLabel.textColor = UIColor.gray; priorityLabel.textColor = UIColor.gray
        } else {
            titleLabel.textColor = UIColor.black; contentLabel.textColor = UIColor.black
            dateLabel.textColor = UIColor.black;  priorityLabel.textColor = UIColor.black
        }
        swipeGesture.isEnabled = true
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
    
    
    @IBAction func swipeUpAction(_ sender: Any) {
            performSegue(withIdentifier: "goDetailPage", sender: nil)
    }
    
    //値の受渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetailPage"{
            let nextVC = segue.destination as! ToDoDetailViewController
            nextVC.titleString = titleLabel.text!
            let realm = try! Realm()
            let todo = realm.objects(ToDo.self).filter(" title == %@", titleLabel.text!).first
            let dateString = DateUtils.stringFromDate(date: todo!.scheduledAt, format: "yyyy年MM月d日")
            nextVC.selectedDateString = dateString
            nextVC.titleString = todo!.title
            nextVC.contentString = todo!.content
            nextVC.priority = todo!.priority
            nextVC.isDone = todo!.isDone
        }
    }
}
