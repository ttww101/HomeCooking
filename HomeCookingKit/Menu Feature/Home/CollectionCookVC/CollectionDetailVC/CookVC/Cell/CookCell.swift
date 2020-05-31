//
//  CookCell.swift
//  HomeCooking
//
//  Created by Apple on 4/23/19.
//  Copyright © 2019 whitelok.com. All rights reserved.
//

import UIKit

class CookCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var cookTitle: UILabel!
    @IBOutlet weak var cookContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
