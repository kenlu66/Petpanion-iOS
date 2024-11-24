//
//  PetStatusViewController.swift
//  Petpanion
//
//  Created by Mengying Jin on 11/9/24.
//

import UIKit

protocol updatePetList {
    func updatePet(pet: Pet, petInd: Int, pList: [Pet], iList: [UIImage])
}

class PetStatusViewController: UIViewController, updatePetList {

    @IBOutlet weak var foodOption: UIButton!
    @IBOutlet weak var waterOption: UIButton!
    @IBOutlet weak var moodOption: UIButton!
    @IBOutlet weak var playtimeOption: UIButton!
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var myHealthButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var petEventLabel: UILabel!
    @IBOutlet weak var optionStackView: UIStackView!
    var currentPosition = 0
    var delegate: UIViewController!
    
    var selectedPet: Pet!
    var petList: [Pet]!
    var imageList: [UIImage]!
    var petImage: UIImage!
    var petIndex: Int!
    var medicalRecord: MedicalInfo!
    var DailyRecord: DailyReportHistory!
    
    let petInfoSegue = "PetStatusToPetInfo"
    let medicalSegue = "PetStatusToMedical"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedPet = petList[petIndex]
        petImage = imageList[petIndex]

        titleLabel.text = "How is \(selectedPet.petName) Doing?"
        petEventLabel.text = "\(selectedPet.petName)'s Event"
        
        foodOption.layer.shadowOpacity = 0.25
        foodOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        waterOption.layer.shadowOpacity = 0.25
        waterOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        moodOption.layer.shadowOpacity = 0.25
        moodOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        playtimeOption.layer.shadowOpacity = 0.25
        playtimeOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        myProfileButton.layer.shadowOpacity = 0.25
        myProfileButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        myHealthButton.layer.shadowOpacity = 0.25
        myHealthButton.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    @IBAction func foodPressed(_ sender: Any) {
        changeViewAnimation(position: 0)
    }
    
    @IBAction func waterPressed(_ sender: Any) {
        changeViewAnimation(position: 1)
    }
    
    @IBAction func moodPressed(_ sender: Any) {
        changeViewAnimation(position: 2)
    }
    
    @IBAction func playtimePressed(_ sender: Any) {
        changeViewAnimation(position: 3)
    }
    
    func changeViewAnimation(position: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let direction = currentPosition - position
        
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.optionStackView.center.x += CGFloat((screenWidth * CGFloat(direction)))
            },
            completion: { finish in
                self.currentPosition = position
            })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == petInfoSegue,
           let petInfoVC = segue.destination as? PetInfoViewController {
            petInfoVC.selectedPet = selectedPet
            petInfoVC.image = petImage
            petInfoVC.petIndex = petIndex
            petInfoVC.petList = petList
            petInfoVC.imageList = imageList
            petInfoVC.delegate = self
        }
        
        if segue.identifier == medicalSegue,
           let medicalVC = segue.destination as? MedicalHistoryViewController {
            
        }
    }
    
    func updatePet(pet: Pet, petInd: Int, pList: [Pet], iList: [UIImage]) {
        // Find the pet in the list and update its information
        print("im in status update pet")
        self.petList = pList
        self.imageList = iList
        self.selectedPet = pet
        if let mainVC = delegate as? changePetList {
            mainVC.updatePet(pet: selectedPet, petInd: petIndex, pList: petList, iList: imageList)
        }
    }
}
