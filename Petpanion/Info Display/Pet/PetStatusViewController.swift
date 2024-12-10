//
//  PetStatusViewController.swift
//  Petpanion
//
//  Created by Mengying Jin on 11/9/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol updatePetList {
    func updatePet(pet: Pet, petInd: Int, pList: [Pet])
}

class PetStatusViewController: UIViewController, updatePetList {
    
    // variables
    let db = Firestore.firestore()

    @IBOutlet weak var foodOption: UIButton!
    @IBOutlet weak var waterOption: UIButton!
    @IBOutlet weak var playtimeOption: UIButton!
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var myHealthButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var petEventLabel: UILabel!
    @IBOutlet weak var optionStackView: UIStackView!
    @IBOutlet weak var foodAmount: UILabel!
    @IBOutlet weak var waterAmount: UILabel!
    @IBOutlet weak var PlaytimeNeeded: UILabel!
    
    var currentPosition = 0
    var delegate: UIViewController!
    
    var selectedPet: Pet!
    var petList: [Pet]!
    var petImage: UIImage!
    var petIndex: Int!
    var medicalRecord: MedicalInfo!
    var allergies: [MedicalInfo.Record] = []
    var vaccines: [MedicalInfo.Record] = []
    var treatments: [MedicalInfo.Record] = []
    var docIDA: String!
    var docIDV: String!
    var docIDT: String!
    
    let petInfoSegue = "PetStatusToPetInfo"
    let allergySegue = "MedicalToAllergies"
    let treatmentSegue = "MedicalToTreatment"
    let vaccineSegue = "MedicalToVaccine"

    // fill in info and layout of elements
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedPet = petList[petIndex]

        titleLabel.text = "How is \(selectedPet.petName) Doing?"
        petEventLabel.text = "\(selectedPet.petName)'s Event"
        
        foodOption.layer.shadowOpacity = 0.25
        foodOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        waterOption.layer.shadowOpacity = 0.25
        waterOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        playtimeOption.layer.shadowOpacity = 0.25
        playtimeOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        myProfileButton.layer.shadowOpacity = 0.25
        myProfileButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        myHealthButton.layer.shadowOpacity = 0.25
        myHealthButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        foodAmount.text = "\(selectedPet.amountPerMeal * selectedPet.mealsPerDay) grams"
        
        waterAmount.text = "\(selectedPet.waterNeeded) milliliters"
        
        PlaytimeNeeded.text = "\(selectedPet.playtimeNeeded) minutes"
    }
    
    // get newest medical records for pets
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchRecords()
    }
    
    // switch to food view
    @IBAction func foodPressed(_ sender: Any) {
        changeViewAnimation(position: 0)
    }
    
    // switch to water view
    @IBAction func waterPressed(_ sender: Any) {
        changeViewAnimation(position: 1)
    }
    
    // switch to playtime view
    @IBAction func playtimePressed(_ sender: Any) {
        changeViewAnimation(position: 2)
    }
    
    // ask for type of medical record
    @IBAction func healthPressed(_ sender: Any) {
        
        // send user to selected record
        let alertController = UIAlertController(title: "Choose Type", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Allergy", style: .default, handler: { _ in
            self.performSegue(withIdentifier: self.allergySegue, sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Treatment", style: .default, handler: { _ in
            self.performSegue(withIdentifier: self.treatmentSegue, sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Vaccine", style: .default, handler: { _ in
            self.performSegue(withIdentifier: self.vaccineSegue, sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // animation for switching views depending on which button is pressed
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
    
    // send info through segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == petInfoSegue,
           let petInfoVC = segue.destination as? PetInfoViewController {
            petInfoVC.selectedPet = selectedPet
            petInfoVC.image = petImage
            petInfoVC.petIndex = petIndex
            petInfoVC.petList = petList
            petInfoVC.image = petImage
            petInfoVC.delegate = self
        }
        
        if segue.identifier == allergySegue,
           let allergyVC = segue.destination as? AllergiesViewController {
            allergyVC.allergyList = allergies
            allergyVC.docID = docIDA
            allergyVC.pet = selectedPet
            allergyVC.delegate = self
        }
        
        if segue.identifier == treatmentSegue,
           let treatmentVC = segue.destination as? TreatmentsViewController {
            treatmentVC.treatmentList = treatments
            treatmentVC.docID = docIDT
            treatmentVC.pet = selectedPet
            treatmentVC.delegate = self
        }
        
        if segue.identifier == vaccineSegue,
           let vaccineVC = segue.destination as? VaccinationsViewController {
            vaccineVC.vaccineList = vaccines
            vaccineVC.docID = docIDV
            vaccineVC.pet = selectedPet
            vaccineVC.delegate = self
        }
    }
    
    // update pet info
    func updatePet(pet: Pet, petInd: Int, pList: [Pet]) {
        // Find the pet in the list and update its information
        print("im in status update pet")
        self.petList = pList
        self.selectedPet = pet
        if let mainVC = delegate as? changePetList {
            mainVC.updatePet(pet: selectedPet, petInd: petIndex, pList: petList)
        }
    }
    
    // get medical records
    func fetchRecords() {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let medicalRef = db.collection("users").document(userId).collection("pets").document(selectedPet.petID).collection("medical records")

        medicalRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error retrieving pets: \(error.localizedDescription)")
                return
            }
            
            self.vaccines = []
            self.allergies = []
            self.treatments = []
            
            for document in snapshot?.documents ?? [] {
                let medicalData = document.data()
                
                guard let type = medicalData["Medical type"] as? String else {
                    print("Error: Missing medical type in document")
                    continue
                }
                
                // assign corresponding document id
                if let docID = medicalData["Document ID"] as? String {
                    switch type {
                    case "Allergy":
                        self.docIDA = docID
                    case "Treatment":
                        self.docIDT = docID
                    case "Vaccine":
                        self.docIDV = docID
                    default:
                        print("error fetching medical document id")
                    }
                }
                // sort the records
                if let records = medicalData["Records"] as? [[String: Any]] {
                    for record in records {
                        if let date = record["date"] as? String,
                           let description = record["description"] as? String,
                           let location = record["location"] as? String {
                            
                            let data = MedicalInfo.Record(description: description, date: date, location: location)
                            
                            switch type {
                            case "Allergy":
                                self.allergies.append(data)
                            case "Treatment":
                                self.treatments.append(data)
                            case "Vaccine":
                                self.vaccines.append(data)
                            default:
                                print("error fetching medical records")
                            }
                        }
                    }
                }
            }
        }
    }
}
