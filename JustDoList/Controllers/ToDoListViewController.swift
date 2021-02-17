//
//  ViewController.swift
//  JustDoList
//
//  Created by evpes on 29.01.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
        
    
    @IBOutlet weak var addButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var todoItems : Results<Item>?
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        loadItems()
        tableView.separatorStyle = .none
        

        
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
                addButtonOutlet.tintColor = ContrastColorOf(color, returnFlat: true)  
                
            }
        }
        
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.standardAppearance = appearance
                        
    }
    
 
    
    //MARK: - TableView DatasourceMethods                   
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.taskName
            cell.accessoryType = item.check ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No added items yet"
        }
        
        if let color = selectedCategory?.color {
            let backgroundColor = UIColor(hexString: color)?.darken(byPercentage:  CGFloat(indexPath.row) / CGFloat((todoItems?.count ?? 1) * 2))
            cell.backgroundColor = backgroundColor
            cell.textLabel?.textColor = ContrastColorOf(backgroundColor!, returnFlat: true)
        }
                
        
        return cell
        
    }
    
    //MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.check = !item.check
                }
            } catch {
                print("Error saving item check :\(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: -  add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new ToDo task", message: "Enter item name", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Task name"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let textField = alert.textFields![0].text {
            if textField.count > 0 {
                    if let currentCategory = self.selectedCategory {
                        do {
                            try self.realm.write {
                                let newItem = Item()
                                newItem.taskName = textField
                                newItem.check = false
                                currentCategory.items.append(newItem)
                            }
                        } catch {
                            print("Error saving categories \(error)")
                        }
                    }
                    self.tableView.reloadData()
                }
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)

        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
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

