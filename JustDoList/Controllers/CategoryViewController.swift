//
//  CategoryViewController.swift
//  JustDoList
//
//  Created by evpes on 04.02.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework
import SwipeCellKit
import SwiftEntryKit

class CategoryViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource, SwipeTableViewCellDelegate {
        
    @IBOutlet weak var tableView: UITableView!
    var categoryArray: Results<ToDoList>?
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = 60
        loadCategories()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID, for: indexPath) as! ListViewCell
        cell.delegate = self
        cell.txtLabel.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
        cell.txtLabel.textColor = .label
        cell.rightImageView.tintColor = UIColor(hexString: categoryArray?[indexPath.row].color ?? "1D9BF6")
        cell.checkButtonOutlet.isHidden = true

        
        return cell
    }
    
    // MARK: - Add new Categories
    
    
    @IBAction func addButtonPressed(_ sender: Any) {

        var attributes = EKAttributes()
        attributes.position = .center
        attributes = .centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.hapticFeedbackType = .success
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        let newCatView = NewListView()
        newCatView.categoryVC = self
        SwiftEntryKit.display(entry: newCatView, using: attributes, presentInsideKeyWindow: true)
    }
    
    
    // MARK: - Data manipulation methods
    func save(category: ToDoList) {
        
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
        
        categoryArray = realm.objects(ToDoList.self)
        tableView.reloadData()
        
    }
    
    //MARK: - Delete data from swipe
    
    func updateModel(at indexPath: IndexPath) {
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: K.segues.segueToTasksView, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("Delete", comment: "") ) { action, indexPath in
            print("Delete Cell")
            
            self.updateModel(at: indexPath)
            
        }

        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = SwipeAction(style: .default, title: NSLocalizedString("Edit", comment: "")) { (action, indexPath) in
            self.editCat(index: indexPath.row)
        }
        
        editAction.image = UIImage(systemName: "pencil")

        return [deleteAction,editAction]

        
    }
    
    func editCat(index: Int) {
        var attributes = EKAttributes()
        attributes.position = .center
        attributes = .centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.hapticFeedbackType = .success
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        let newCatView = NewListView()
        newCatView.categoryVC = self
        newCatView.setIndex(index: index)
        SwiftEntryKit.display(entry: newCatView, using: attributes, presentInsideKeyWindow: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
}



