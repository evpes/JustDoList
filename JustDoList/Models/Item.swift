//
//  ItemModel.swift
//  JustDoList
//
//  Created by evpes on 31.01.2021.
//

import Foundation

class Item : Codable {
    var taskName: String
    var check: Bool = false
    
    init(taskName:String ,check: Bool) {
        self.taskName = taskName
        self.check = check
    }
}
