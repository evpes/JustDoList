//
//  ToDoList.swift
//  JustDoList
//
//  Created by evpes on 08.02.2021.
//

import Foundation
import RealmSwift

class ToDoList: Object {
    @objc dynamic var name: String = ""
    let tasks = List<Task>()
    @objc dynamic var color = ""
}
