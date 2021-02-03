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
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        loadData()
        if let array = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemAray = array
        }
    }
    
    //MARK - TableView DatasourceMethods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemAray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        let item = itemAray[indexPath.row]
        cell.textLabel?.text = item.taskName
        cell.accessoryType = item.check ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemAray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        itemAray[indexPath.row].check = !itemAray[indexPath.row].check
        tableView.reloadData()
        self.saveData()
    }
    
    //MARK -  add new items
    
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
                    self.itemAray.append(newItem)
                    self.saveData()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model manipulation methods
    
    func saveData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadData() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        do {
         itemAray = try context.fetch(request)
        } catch {
            print("Error fetching data from request \(error)")
        }
    }
}

