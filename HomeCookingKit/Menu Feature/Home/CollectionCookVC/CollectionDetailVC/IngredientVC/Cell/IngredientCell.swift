//
//  IngredientCell.swift
//  HomeCooking
//
//  Created by Apple on 4/22/19.
//  Copyright © 2019 whitelok.com. All rights reserved.
//

import UIKit

class IngredientCell: UITableViewCell {
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        self.bgView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
