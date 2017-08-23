//
//  PostTextViewCell.swift
//  Salaam
//
//  Created by basira daqiq on 7/12/17.
//  Copyright © 2017 Make School. All rights reserved.
//
// 22 everything updated

import UIKit

class PostTextViewCell: UITableViewCell {
    
    
    @IBOutlet weak var textView: UITextView!
    
    

    
    
   // @IBOutlet weak var postImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


// connect uitextview, likes to PostImageCell class
// pull posts from Firebase and load post info into the above fields
