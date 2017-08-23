//
//  PostActionCell.swift
//  Salaam
//
//  Created by basira daqiq on 7/12/17.
//  Copyright © 2017 Make School. All rights reserved.
// the new jeffery one 

import UIKit

protocol PostActionCellDelegate: class {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell)
}



class PostActionCell: UITableViewCell {
    static let height: CGFloat = 46
    static let width: CGFloat = 46

    @IBOutlet weak var likeCountLabel : UILabel!
    @IBOutlet weak var likeButton : UIButton!
    @IBOutlet weak var timeAgoLabel : UILabel!

    weak var delegate: PostActionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonTapped(_ sender : UIButton) {
        delegate?.didTapLikeButton(sender, on: self)        
    }

}


