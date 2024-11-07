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
    @IBOutlet weak var viewBox: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with image: UIImage, name: String) {
        petImage.image = image
        petName.text = name
        
        petImage.layer.cornerRadius = 25
        viewBox.layer.cornerRadius = 25
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "PetCollectionViewCell", bundle: nil)
    }

}
