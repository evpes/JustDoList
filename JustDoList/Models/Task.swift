//
//  Item.swift
//  JustDoList
//
//  Created by evpes on 08.02.2021.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var taskName: String = ""
    @objc dynamic var check: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var notificationDate: Date?
    var parentCategory = LinkingObjects(fromType: ToDoList.self, property: "tasks")
}
