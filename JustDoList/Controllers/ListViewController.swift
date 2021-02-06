//
//  CategoryViewController.swift
//  JustDoList
//
//  Created by evpes on 04.02.2021.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {
    
    var listsArray = [List]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLists()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.listCellId, for: indexPath)
        let list = listsArray[indexPath.row]
        cell.textLabel?.text = list.name
        return cell
    }

    // MARK: - Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new list", message: "Enter list name", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "List name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            if let textField = alert.textFields![0].text {
                if textField.count > 0 {
                    let newList = List(context: self.context)
                    newList.name = textField
                    self.listsArray.append(newList)
                    self.saveCategories()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

    
    // MARK: - Data manipulation methods
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving categories context: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadLists() {
        let request : NSFetchRequest<List> = List.fetchRequest()
        do {
            listsArray = try context.fetch(request)
        } catch {
            print("Error loading categories context: \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
        destinationVC.selectedList = listsArray[indexPath.row]
        }
        
    }
    
    
}


