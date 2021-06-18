//
//  TableViewCell.swift
//  login
//
//  Created by Diego Zamora on 17/06/21.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    // MARK: - Variables Globales y Outlets
    @IBOutlet weak var foto: UIImageView!
    @IBOutlet weak var nombre: UILabel!
    @IBOutlet weak var texto: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
