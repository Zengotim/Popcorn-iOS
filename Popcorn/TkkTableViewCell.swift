//
//  TkkTableViewCell.swift
//  Popcorn
//
//  Created by Timothy Goodson on 5/19/16.
//  Copyright © 2016 TK-Squared, LLC. All rights reserved.
//

import UIKit

class TkkTableViewCell: UITableViewCell {

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
