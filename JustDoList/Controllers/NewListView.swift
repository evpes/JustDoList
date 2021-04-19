//
//  NewCategoryView.swift
//  JustDoList
//
//  Created by evpes on 04.03.2021.
//

import UIKit
import SwiftEntryKit
import RealmSwift
import Combine

class NewListView: UIViewController, UITextFieldDelegate {
    @IBOutlet var listView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var listColor: UIButton!
    var color = UIColor.randomFlat()
    var cancellable: AnyCancellable?
    
    var categoryVC: CategoryViewController?
    var listIndex: Int?
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        Bundle.main.loadNibNamed(K.listViewXib , owner: self, options: nil)
        listView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layer.cornerRadius = 10
        self.view.superview?.layer.cornerRadius = 2.0
//        self.view.layer.masksToBounds = true
        self.view.layer.isOpaque = false
        self.view.layer.borderWidth = 1
        self.view.layer.borderColor = UIColor.white.cgColor
        self.textField.becomeFirstResponder()
        self.listView.heightAnchor.constraint(equalToConstant: 350 ).isActive = true
        self.listView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10 ).isActive = true
        self.textField.becomeFirstResponder()
        listColor.tintColor = color
        if let i = listIndex {
            let cat = realm.objects(ToDoList.self)[i]
            textField.text = cat.name
            topLabel.text = NSLocalizedString("Edit category", comment: "")
        }
    }
    
    func setIndex(index: Int) {
        listIndex = index
    }
    
    //MARK:- buttons
    
    @IBAction func okButtonPressed(_ sender: Any) {
        print("ok")
        
        if let txt = textField.text {
            if txt.count > 0 {
                if let index = listIndex {
                    let cat = realm.objects(ToDoList.self)[index]
                    try! realm.write {
                        cat.setValue(txt, forKey: "name")
                        cat.setValue(color.hexValue(), forKey: "color")
                    }
                    categoryVC?.tableView.reloadData()
                } else {
                    let newCategory = ToDoList()
                    newCategory.name = txt
                    newCategory.color = color.hexValue()
                    self.save(category: newCategory)
                }
            }
        }
        SwiftEntryKit.dismiss()
    }
    
    @IBAction func cancellButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    @IBAction func changeListColor(_ sender: UIButton) {
        if #available(iOS 14.0, *) {
            print("color")
            let picker = UIColorPickerViewController()
            picker.selectedColor = color
            self.cancellable = picker.publisher(for: \.selectedColor)
                .sink(receiveValue: { (selectedColor) in
                    DispatchQueue.main.async {
                        self.color = selectedColor
                        self.listColor.tintColor = self.color
                    }
                })
            self.present(picker,animated: true,completion: nil)
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    //MARK:- data manipulation methods
    
    func save(category: ToDoList) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving categories context: \(error)")
        }
        
        categoryVC?.tableView.reloadData()
        
    }
    
    //MARK:- TextFieldDelegate functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.listView.endEditing(true)
        return false
    }
    
    
}
