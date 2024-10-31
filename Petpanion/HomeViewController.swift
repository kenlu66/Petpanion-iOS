//
//  HomeViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol updatePetList {
    func updatePet(pet: Pet)
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, updatePetList {
    
    let db = Firestore.firestore()
    
    var petList: [Pet] = []
    @IBOutlet weak var tableView: UITableView!
    let textCellIdentifier = "PetCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchPets()
    }
    
    func fetchPets() {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        // Reference to the pets subcollection for the authenticated user
        let petsRef = db.collection("users").document(userId).collection("pets")
        
        // Retrieve pets associated with the user
        petsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error retrieving pets: \(error.localizedDescription)")
                return
            }
            
            // Process the retrieved documents
            self.petList = [] // Clear existing pet list
            for document in snapshot?.documents ?? [] {
                let petData = document.data()
                if let petName = petData["petName"] as? String,
                   let breedName = petData["breedName"] as? String,
                   let neutered = petData["neutered"] as? String,
                   let age = petData["age"] as? Int,
                   let weight = petData["weight"] as? Float,
                   let gender = petData["gender"] as? String,
                   let petDescription = petData["petDescription"] as? String {
                    
                    let pet = Pet(petName: petName,
                                  breedName: breedName,
                                  neutered: neutered,
                                  age: age,
                                  weight: weight,
                                  gender: gender,
                                  petDescription: petDescription)
                    self.petList.append(pet)
                }
            }

            // Update the table view with the new data
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
          
        // Put pizza detail into cell
        cell.textLabel?.numberOfLines = 5 // Five lines for all information to show
        cell.textLabel?.text = petList[row].petName
        
        return cell
    }
    
    // Set up segues to pizza creation view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToProfileCreation",
           let petCreationVC = segue.destination as? ProfileCreationViewController {
            petCreationVC.delegate = self // pointer back to main VC
        }
        
        if segue.identifier == "HomeToPetInfo",
           let destination = segue.destination as? PetInfoViewController,
           // Pass the operator type selected into next VC
           let petIndex = tableView.indexPathForSelectedRow?.row {
            destination.selectedPet = petList[petIndex]
        }
    }
    
    func updatePet(pet: Pet) {
        self.petList.append(pet)
        self.tableView.reloadData()
    }
}
