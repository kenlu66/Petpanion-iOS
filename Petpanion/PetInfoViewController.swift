//
//  PetInfoViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit

class PetInfoViewController: UIViewController {

    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var breedType: UILabel!
    @IBOutlet weak var aboutPet: UILabel!
    @IBOutlet weak var descriptionField: UILabel!
    @IBOutlet weak var statusTitle: UILabel!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var age: UILabel!
    
    var selectedPet: Pet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        petImage.layer.masksToBounds = true
        petImage.layer.cornerRadius = petImage.frame.height / 2
        
        genderImage.layer.cornerRadius = 10
        genderImage.layer.masksToBounds = true
        
        petName.text = selectedPet.petName
        breedType.text = selectedPet.breedName
        age.text = "\(selectedPet.age)"
        weight.text = "\(selectedPet.weight)"
        descriptionField.text = selectedPet.petDescription
    }
    

}
