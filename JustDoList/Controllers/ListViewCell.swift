//
//  CategoryViewCell.swift
//  JustDoList
//
//  Created by evpes on 17.02.2021.
//

import UIKit
import SwipeCellKit

class ListViewCell: SwipeTableViewCell {

    
    @IBOutlet weak var checkButtonOutlet: UIButton!
    @IBOutlet weak var txtLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
