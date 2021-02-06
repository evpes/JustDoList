//
//  ViewController.swift
//  JustDoList
//
//  Created by evpes on 29.01.2021.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemAray : [Item] = []
    var selectedList : List? {
        didSet {
            loadData()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        loadData()
        
    }
    
    //MARK: - TableView DatasourceMethods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemAray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.itemCellID, for: indexPath)
        let item = itemAray[indexPath.row]
        cell.textLabel?.text = item.taskName
        cell.accessoryType = item.check ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        //        context.delete(itemAray[indexPath.row])
        //        itemAray.remove(at: indexPath.row)
        itemAray[indexPath.row].check = !itemAray[indexPath.row].check
        self.saveData()
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
                    let newItem = Item(context: self.context)
                    newItem.taskName = textField
                    newItem.check = false
                    newItem.parentCategory = self.selectedList
                    self.itemAray.append(newItem)
                    self.saveData()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    
    func saveData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let listPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedList!.name!)
        
        if let additionalPredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [listPredicate, additionalPredicate])
            
            request.predicate  = compoundPredicate
        } else {
            request.predicate = listPredicate
        }
        
        
        do {
            itemAray = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error fetching data from request \(error)")
        }
    }
    
    
}

//MARK: - search bar methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        if let text = searchBar.text {
            if text.count > 0 {
                let predicate = NSPredicate(format: "taskName CONTAINS[cd] %@", text)
                request.sortDescriptors = [NSSortDescriptor(key: "taskName", ascending: true)]
                loadData(with: request, predicate: predicate)
            } else {
                loadData()
            }
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        if searchText.count > 0 {
            let predicate = NSPredicate(format: "taskName CONTAINS[cd] %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "taskName", ascending: true)]
            loadData(with: request, predicate: predicate)
        } else {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
}
