//
//  K.swift
//  JustDoList
//
//  Created by evpes on 29.01.2021.
//

import Foundation

struct K {
    static let cellID = "Cell"
    static let cellNibName = "ListViewCell"
    static let listViewXib = "NewListView"
    static let taskViewXib = "NewTaskView"
    
    struct segues {
        static let segueToTasksView = "toTasks"
    }
    
    struct settings {
        static let visibilitySetting = "taskVisibility"
        static let colorSetting = "colorScheme"
        static let sortSetting = "sortBy"
    }
}
