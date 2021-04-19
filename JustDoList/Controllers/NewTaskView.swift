//
//  NewTaskView.swift
//  JustDoList
//
//  Created by evpes on 04.03.2021.
//

import UIKit
import RealmSwift
import SwiftEntryKit

class NewTaskView: UIViewController, UITextFieldDelegate {
    
    var windowsPopUp: UIWindow?
    @IBOutlet var itemView: UIView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var notificationDate: UIDatePicker!
    @IBOutlet weak var notificationSwitchOutlet: UISwitch!
    @IBOutlet weak var topLabel: UILabel!
    
    var selectedCategory : ToDoList?
    var itemVC: ToDoListViewController?
    var taskIndex: Int?
    var todoItems : Results<Task>?
    var itemName: String?
    var myViewHeightConstraint: NSLayoutConstraint!
    
    let realm = try! Realm()
    
    let notificationCenter = UNUserNotificationCenter.current()
        
    override func viewDidLoad() {
        setup()
        notificationDate.isEnabled = false
        self.textField.delegate = self
        self.textField.becomeFirstResponder()
        myViewHeightConstraint = itemView.heightAnchor.constraint(equalToConstant: 300 )
        myViewHeightConstraint.isActive = true
        if let index = taskIndex {
            if let item = todoItems?[index] {
                itemName = item.taskName
                
                textField.text = itemName
                topLabel.text = NSLocalizedString("Edit task", comment: "")

                if let notDate = item.notificationDate {
                    myViewHeightConstraint.constant = 510
                    notificationDate.date = notDate
                    notificationSwitchOutlet.setOn(true, animated: false)
                    notificationDate.isHidden = false
                    notificationDate.isEnabled = true
                    
                } else {
                    myViewHeightConstraint.constant = 300
                }
            }

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layer.cornerRadius = 10
        self.view.superview?.layer.cornerRadius = 2.0
        self.view.layer.masksToBounds = true
        self.view.layer.isOpaque = false
        self.view.layer.borderWidth = 1
        self.view.layer.borderColor = UIColor.white.cgColor
        self.textField.becomeFirstResponder()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.textField.becomeFirstResponder()
        DispatchQueue.main.async {
            self.textField.becomeFirstResponder()
        }
    }
    
    private func setup() {
        print("setup")
        Bundle.main.loadNibNamed(K.taskViewXib, owner: self, options: nil)
        itemView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        itemView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10 ).isActive = true
        self.view.layer.cornerRadius = 10
    }
    
    func setIndex(index: Int) {
            taskIndex = index
    }
    
    //MARK:- buttons
    
    @IBAction func notificationSwitch(_ sender: UISwitch) {
        if sender.isOn {
            
            AnimateBackgroundHeight(expand: true)
            notificationDate.isHidden = false
            notificationCenter.getNotificationSettings { (settings) in
                if settings.authorizationStatus != .authorized {
                    // Notifications not allowed
                    DispatchQueue.main.async {
                        self.displayAlert()
                        sender.isOn = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.notificationDate.isEnabled = true
                    }
                }
            }
            
            
        } else {
            AnimateBackgroundHeight(expand: false)
            notificationDate.isHidden = true
            notificationDate.isEnabled = false
            if let name = itemName {
                self.deleteNotification(with: name)
            }
        }
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        if let txt = textField.text, let VC = itemVC {
            if txt.count > 0 {
                if let currentCategory = self.selectedCategory {
                    if let index = taskIndex {
                        if let item = todoItems?[index] {
                            do {
                                try realm.write {
                                    item.taskName = txt
                                    item.notificationDate = notificationDate.date
                                    if !notificationSwitchOutlet.isOn {
                                        item.notificationDate = nil
                                    }
                                }
                            } catch {
                                print("Error saving item check :\(error)")
                            }
                            if notificationSwitchOutlet.isOn {
                                scheduleNotification(notificationType: txt, notificationDate: notificationDate.date)
                            }
                        }
                    } else {
                        do {
                            try self.realm.write {
                                let newItem = Task()
                                newItem.taskName = txt
                                newItem.check = false
                                currentCategory.tasks.append(newItem)
                                if notificationSwitchOutlet.isOn {
                                    newItem.notificationDate = notificationDate.date
                                    scheduleNotification(notificationType: txt, notificationDate: notificationDate.date)
                                }
                            }
                        } catch {
                            print("Error saving categories \(error)")
                        }
                    }
                    
                }
                VC.tableView.reloadData()
            }
        }
        SwiftEntryKit.dismiss()
    }
    
    @IBAction func dateValueChanged(_ sender: UIDatePicker) {
        print(sender.date)
        
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
        
        itemVC?.tableView.reloadData()
        
    }
    
    //MARK:- Notifications
    
    func scheduleNotification(notificationType: String, notificationDate: Date) {
        
        //setup content
        let content = UNMutableNotificationContent() // notification content
        let userActions = "User Actions"
        content.title = NSLocalizedString("Notification", comment: "")
        content.body = "" + notificationType + ""
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = userActions
        content.targetContentIdentifier = notificationType
        
        //setup trigger
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let identifier = notificationType
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        //add notification
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        //setup notification categories
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: NSLocalizedString("Snooze", comment: ""), options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: NSLocalizedString("Delete", comment: ""), options: [.destructive])
        let category = UNNotificationCategory(identifier: userActions, actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    func deleteNotification(with task: String) {
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
            var identifiers:[String] = []
            for n in notifications {
                
                if n.identifier == task {
                    identifiers.append(n.identifier)
                    print(n.identifier)
                }
                center.removePendingNotificationRequests(withIdentifiers: identifiers)
            }
        }
    }
    
    //MARK:- alert functions
    
    func displayAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Notifications disabled", comment: ""), message: NSLocalizedString("To turn on notifications, you need enable notifications in Settings -> List -> Notifications", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default , handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open Settings", comment: ""), style: .cancel, handler: { (action) in
            print("Open Settings")
            if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        }))
        UIApplication.shared.windows.last?.rootViewController?.present(alert, animated: true)
    }
    
    //MARK:- TextFieldDelegate functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.itemView.endEditing(true)
        return false
    }
    
    func AnimateBackgroundHeight(expand: Bool) {
        if expand {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.myViewHeightConstraint.constant = 510 // heightCon is the IBOutlet to the constraint
                     //self.itemView.layoutIfNeeded()
                })
            }
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.myViewHeightConstraint.constant = 300 // heightCon is the IBOutlet to the constraint
                     //self.itemView.layoutIfNeeded()
                })
            }
        }
    }

}

extension UIView {
    func makeCorner(withRadius radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.isOpaque = false
    }
}







