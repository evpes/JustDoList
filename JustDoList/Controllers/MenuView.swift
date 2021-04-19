//
//  MenuView.swift
//  JustDoList
//
//  Created by evpes on 27.02.2021.
//

import UIKit
import SwiftEntryKit

class MenuView: UIView {
    
    @IBOutlet weak var okButtonOutlet: UIButton!
    @IBOutlet var menuView: UIView!
    @IBOutlet weak var taskVisibility: UISegmentedControl!
    @IBOutlet weak var colorScheme: UISegmentedControl!
    @IBOutlet weak var sortTasksBy: UISegmentedControl!
    var itemVC: ToDoListViewController?     
    var settings = ["taskVisibility" : 0, "colorScheme" : 1, "sortBy" : 0]
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Settings.plist")
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 350 ).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10 ).isActive = true
        backgroundColor = .black
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)
        addSubview(menuView)
        menuView.frame = self.bounds
        menuView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.isOpaque = false
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        
        clipsToBounds = true
        loadSettings()
        //setup settings segments from file
        for s in settings {
            switch s.key {
            case K.settings.visibilitySetting:
                taskVisibility.selectedSegmentIndex = s.value
            case K.settings.colorSetting:
                colorScheme.selectedSegmentIndex = s.value
            case K.settings.sortSetting:
                sortTasksBy.selectedSegmentIndex = s.value
            default:
                print("default")
            }
        }
    }
    
    //MARK: - change settings functions
    
    @IBAction func changeTaskVisibility(_ sender: UISegmentedControl) {
        settings[K.settings.visibilitySetting] = sender.selectedSegmentIndex
        saveSettings()
        reloadParentView()
    }
    
    @IBAction func changeColorScheme(_ sender: UISegmentedControl) {
        settings[K.settings.colorSetting] = sender.selectedSegmentIndex
        saveSettings()
        reloadParentView()
    }
        
    @IBAction func changeSortBy(_ sender: UISegmentedControl) {
        settings[K.settings.sortSetting] = sender.selectedSegmentIndex
        saveSettings()
        reloadParentView()
    }
    
    func reloadParentView() {
        if let VC = itemVC {
            VC.loadSettings()
            VC.loadItems()
            UIView.transition(with: VC.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {VC.tableView.reloadData()}, completion: nil)        }
    }
    
    //MARK: - Data persistance functions
    
    func saveSettings() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.settings)
            try data.write(to: self.dataFilePath! )
            
        } catch {
            print("Error encoding settings dict \(error)")
        }
    }
    
    
    @IBAction func button(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    func loadSettings() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                settings = try decoder.decode([String : Int].self, from: data)
            } catch {
                print("Error decoding data to settings dict \(error)")
            }
        }
        
    }
    
    
}
