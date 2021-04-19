//
//  ViewController.swift
//  JustDoList
//
//  Created by evpes on 29.01.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework
import SwipeCellKit
import SwiftEntryKit

class ToDoListViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource, SwipeTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Settings.plist")
    var settings: [String : Int]?
    let realm = try! Realm()
    var todoItems : Results<Task>?
    var selectedCategory : ToDoList? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //menuView = Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)?.first as! UIView
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view
        self.tableView.rowHeight = 60
        loadSettings()
        loadItems()
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appearance = UINavigationBarAppearance()
        
        title = selectedCategory?.name
        
        if let hexColor = selectedCategory?.color {
            if let color = UIColor(hexString: hexColor) {
                appearance.backgroundColor = color
                appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(color, returnFlat: true)]
                navigationController?.navigationBar.tintColor = ContrastColorOf(color, returnFlat: true)                
                searchBar.barTintColor = color
                //addButtonOutlet.tintColor = ContrastColorOf(color, returnFlat: true)
                
            }
        }
        
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.standardAppearance = appearance
        
    }
    
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
        let attributes = prepareAttributes()
        let menuView = MenuView()
        menuView.itemVC = self
        SwiftEntryKit.display(entry: menuView, using: attributes)
        
    }
    
    
    //MARK: - TableView DatasourceMethods                   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID, for: indexPath) as! ListViewCell
        cell.delegate = self
        
        if let item = todoItems?[indexPath.row] {
            cell.txtLabel.text = item.taskName
            cell.accessoryType = item.check ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No added tasks yet"
        }
        
        if let set = settings {
            if set[K.settings.colorSetting] == 0 {
                if let color = selectedCategory?.color {
                    let backgroundColor = UIColor(hexString: color)?.darken(byPercentage:  CGFloat(indexPath.row) / CGFloat((todoItems?.count ?? 1) * 2))
                    cell.backgroundColor = backgroundColor
                    cell.txtLabel.textColor = ContrastColorOf(backgroundColor!, returnFlat: true)
                }
            } else {
                cell.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
                //cell.txtLabel.textColor = .black
            }
        }
        cell.txtLabel.textColor = .label
        
        cell.checkButtonOutlet.isHidden = true
        cell.rightImageView.isHidden = true
        
        return cell
    }
    
    //MARK: - TableView Delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.check = !item.check
                }
            } catch {
                print("Error saving item check :\(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        
    }
    
    //MARK: -  add new tasks
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let attributes = prepareAttributes()
        let newTaskView = NewTaskView()
        newTaskView.itemVC = self
        newTaskView.selectedCategory = selectedCategory
        SwiftEntryKit.display(entry: newTaskView, using: attributes, presentInsideKeyWindow: true)
    }
    
    
    //MARK: - Model manipulation methods
    
    
    func loadItems() {
        
        todoItems = selectedCategory?.tasks.sorted(byKeyPath: "dateCreated", ascending: false)
        if let set = settings {
            print("load")
            if set["taskVisibility"] == 1 {
                print("load")
                todoItems = todoItems?.filter("check == %@", false)
            }
            if set[K.settings.sortSetting] == 1 {
                todoItems = todoItems?.sorted(byKeyPath: "taskName", ascending: true)
            }
        }
        
    }
    
    func loadSettings() {
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                settings = try decoder.decode([String : Int].self, from: data)
            } catch {
                print("Error decoding datd to settings dict \(error)")
            }
        }
    }
    
    func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting item :\(error)")
            }
        }
    }
    
    func updateTask(index: Int) {
        let attributes = prepareAttributes()
        let newTaskView = NewTaskView()
        newTaskView.itemVC = self
        newTaskView.selectedCategory = selectedCategory
        newTaskView.todoItems = todoItems
        newTaskView.setIndex(index: index)
        //newTaskView.layer.borderWidth = 4
        //newTaskView.layer.borderColor = UIColor.black.cgColor
        
        SwiftEntryKit.display(entry: newTaskView, using: attributes,presentInsideKeyWindow: true)
    }
    
    func prepareAttributes() -> EKAttributes {
        var attributes = EKAttributes()
        attributes.position = .top
        attributes = .topFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.hapticFeedbackType = .success
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.windowLevel = .normal
        attributes.roundCorners = .all(radius: 10.0)
        return attributes
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { action, indexPath in
            print("Delete Cell")
            
            self.updateModel(at: indexPath)
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")
        let editAction = SwipeAction(style: .default, title: NSLocalizedString("Edit", comment: "")) { (action, indexPath) in
            print("edit")
            self.updateTask(index: indexPath.row)
        }
        
        editAction.image = UIImage(systemName: "pencil")
        
        return [deleteAction,editAction]
        
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
}

//MARK: - search bar methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("taskName CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text!.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

