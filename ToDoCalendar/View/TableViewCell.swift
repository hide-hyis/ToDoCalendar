//
//  inputTextTableViewCell.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/06/03.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
    func textFieldDidEndEditing(cell: TableViewCell, value: String)
    func textfieldsSouldChangeCharactersIn(cell: TableViewCell, value: String)
    func textFieldDidBeginEditing(cell: TableViewCell, value: String)
    func textFieldShouldEndEditing(cell: TableViewCell, value: String)
}

class TableViewCell: UITableViewCell, UITextFieldDelegate {

    var delegate: TableViewCellDelegate! = nil

    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
//        textField.isEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditingr")
        self.delegate.textFieldDidEndEditing(cell: self, value: textField.text!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.delegate.textfieldsSouldChangeCharactersIn(cell: self, value: textField.text!)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate.textFieldDidBeginEditing(cell: self, value: textField.text!)
        print("テキストフィールがタップされ、入力可能になったあと")
    }
    
    func textFieldShouldEndEditing(_ textField:UITextField) -> Bool {
        self.delegate.textFieldShouldEndEditing(cell: self, value: textField.text!)
        print("キーボードを閉じる前")
       return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
