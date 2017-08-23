//
//  PostHeaderCell.swift
//  Salaam
//
//  Created by basira daqiq on 7/12/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {
    // flag 2
    var didTapOptionsButtonForCell: ((PostHeaderCell) -> Void)?
    
    
    
    static let height: CGFloat = 54
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        /// flag 3
        didTapOptionsButtonForCell?(self)
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
