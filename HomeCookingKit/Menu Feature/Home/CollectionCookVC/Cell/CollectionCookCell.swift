//
//  CollectionCookCell.swift
//  HomeCooking
//
//  Created by Apple on 4/22/19.
//  Copyright © 2019 whitelok.com. All rights reserved.
//

import UIKit

class CollectionCookCell: UITableViewCell {
    @IBOutlet weak var collectImage: UIImageView!
    @IBOutlet weak var collectTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
