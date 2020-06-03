////
////  InputTextCell.swift
////  ToDoCalendar
////
////  Created by Ishii Hideyasu on 2020/06/03.
////  Copyright © 2020 Ishii Hideyasu. All rights reserved.
////
//
//import UIKit
//
//protocol TableViewCellDelegate {
//    func textFieldDidEndEditing(cell: InputTextCell, value: String) -> ()
//}
//
//class InputTextCell: UITableViewCell, UITextFieldDelegate {
//
//    var delegate: TableViewCellDelegate! = nil
//
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        textField.delegate = self
//        textField.returnKeyType = .done
//
//        // To prevent the TextField from being edited in the initial display
//        textField.isEnabled = false
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.delegate.textFieldDidEndEditing(cell: self, value: textField.text!)
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//}
//
