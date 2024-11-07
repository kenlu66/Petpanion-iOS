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

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, updatePetList {
    
    let db = Firestore.firestore()
    
    var petList: [Pet] = []
    let textCellIdentifier = "PetCell"
    let collectionViewIdentifier = "PetCollectionViewCell"
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(PetCollectionViewCell.nib(), forCellWithReuseIdentifier: collectionViewIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewIdentifier, for: indexPath) as! PetCollectionViewCell
        let row = indexPath.row
        cell.configure(with: UIImage(named: "Petpanion_iconV1")!, name: petList[row].petName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get the selected pet from your petList
        let selectedPet = petList[indexPath.row]
        
        // Perform the segue to the next view controller (PetInfoViewController)
        performSegue(withIdentifier: "HomeToPetInfo", sender: selectedPet)
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
            let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            let selectedPet = petList[selectedIndexPath.row]
            destination.selectedPet = selectedPet
        }
        
    }
    
    func updatePet(pet: Pet) {
        let newIndex = petList.count
        petList.append(pet)
        
        // Insert the new item at the end of the collection view
        let indexPath = IndexPath(item: newIndex, section: 0)
        collectionView.insertItems(at: [indexPath])
    }

}
