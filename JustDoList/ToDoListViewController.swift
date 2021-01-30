//
//  ViewController.swift
//  JustDoList
//
//  Created by evpes on 29.01.2021.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemAray = ["Buy apples","Buy sourcream","Go to pool"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK - TableView DatasourceMethods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemAray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        cell.textLabel?.text = itemAray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemAray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType  = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType  = .checkmark
        }
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
                self.itemAray.append("\(textField)")
                self.tableView.reloadData()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
}

