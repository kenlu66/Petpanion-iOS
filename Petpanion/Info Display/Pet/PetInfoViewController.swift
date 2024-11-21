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
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var age: UILabel!
    
    @IBOutlet weak var designBox1: UIView!
    @IBOutlet weak var designBoxAge: UIView!
    @IBOutlet weak var designerBoxWeight: UIView!
    
    var selectedPet: Pet!
    var image: UIImage!
    var delegate: UIViewController!
    let creationSegue = "PetInfoToCreation"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designBox1.layer.cornerRadius = 10
        designBox1.layer.shadowOpacity = 0.25
        designBox1.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        designBoxAge.layer.cornerRadius = 10
        designBoxAge.layer.shadowOpacity = 0.25
        designBoxAge.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        designerBoxWeight.layer.cornerRadius = 10
        designerBoxWeight.layer.shadowOpacity = 0.25
        designerBoxWeight.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        petImage.layer.masksToBounds = true
        petImage.layer.cornerRadius = petImage.frame.height / 2
        petImage.image = image
        
        genderImage.layer.cornerRadius = 10
        genderImage.layer.masksToBounds = true
        
        petName.text = selectedPet.petName
        breedType.text = selectedPet.breedName
        age.text = "\(selectedPet.age)"
        weight.text = "\(selectedPet.weight)"
        descriptionField.text = selectedPet.petDescription
        
        if selectedPet.gender == "Male" {
            genderImage.image = UIImage(named: "Male Icon")
        } else if selectedPet.gender == "Female" {
            genderImage.image = UIImage(named: "Female icon")
        } else if selectedPet.gender == "Other" {
            genderImage.image = UIImage(named: "Other Icon")
        }
        
    }
    
    func convertDataToImage(imageData: String) -> UIImage? {
        if let data = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == creationSegue,
           let petCreationVC = segue.destination as? ProfileCreationViewController {
            petCreationVC.status = "update"
            petCreationVC.selectedPet = selectedPet
            petCreationVC.image = image
            petCreationVC.delegate = self // pointer back to main VC
        }
    }
    
}
