//
//  PostCollectionViewCell.swift
//  Petpanion
//
//  Created by Ruolin Dong on 11/9/24.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    // variables
//    @IBOutlet var petImage: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
//    @IBOutlet weak var viewBox: UIView! // For future design use
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with image: UIImage, postTitle: String) {
//        petImage.image = image
        postTitleLabel.text = postTitle
        
//        petImage.layer.cornerRadius = 25
//        viewBox.layer.cornerRadius = 25
    }
    
    // Get the layout from xib file
    static func nib() -> UINib {
        return UINib(nibName: "PostCollectionViewCell", bundle: nil)
    }
    
}
