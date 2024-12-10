//
//  PetCollectionViewCell.swift
//  Petpanion
//
//  Created by Mengying Jin on 11/4/24.
//

import UIKit

class PetCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var petImage: UIImageView!
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var viewBox: UIView! // For design use
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // set up cell UI
    public func configure(with image: UIImage, name: String) {
        petImage.image = image
        petName.text = name
        
        petImage.layer.cornerRadius = 25
        viewBox.layer.cornerRadius = 25
    }
    
    // Get the layout from xib file
    static func nib() -> UINib {
        return UINib(nibName: "PetCollectionViewCell", bundle: nil)
    }

}
