//
//  Item.swift
//  JustDoList
//
//  Created by evpes on 08.02.2021.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var taskName: String = ""
    @objc dynamic var check: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
