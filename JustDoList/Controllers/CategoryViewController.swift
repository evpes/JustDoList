//
//  CategoryViewController.swift
//  JustDoList
//
//  Created by evpes on 04.02.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
        
    
    var categoryArray: Results<Category>?
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 60
        loadCategories()
        //tableView.separatorStyle = .singleLine
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellID)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = #colorLiteral(red: 0.03756164014, green: 0.4884038568, blue: 0.6257488728, alpha: 1)

        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.standardAppearance = appearance
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! CategoryViewCell
        cell.txtLabel.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
        cell.rightImageView.tintColor = UIColor(hexString: categoryArray?[indexPath.row].color ?? "1D9BF6")
        cell.checkButtonOutlet.isHidden = true
//        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
//        
//        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].color ?? "1D9BF6")
        
        return cell
    }
    
    // MARK: - Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new category", message: "Enter category name", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "List name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            if let textField = alert.textFields![0].text {
                if textField.count > 0 {
                    let newCategory = Category()
                    newCategory.name = textField
                    newCategory.color = UIColor.randomFlat().hexValue()
                    self.save(category: newCategory)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Data manipulation methods
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving categories context: \(error)")
        }
        self.tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
        
    }
    
    //MARK: - Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let category = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print("Error saving categories context: \(error)")
            }
            
        }

    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
}



