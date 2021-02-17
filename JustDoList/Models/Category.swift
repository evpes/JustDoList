//
//  List.swift
//  JustDoList
//
//  Created by evpes on 08.02.2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
    @objc dynamic var color = ""
}
