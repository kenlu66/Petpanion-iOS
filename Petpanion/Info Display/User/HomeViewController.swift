//
//  HomeViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol changePetList {
    func updatePet(pet: Pet, petInd: Int, pList: [Pet], iList: [UIImage])
    func addPet(pet: Pet)
}

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, changePetList {
    
    let db = Firestore.firestore()
    let storageManager = StorageManager()
    
    var petList: [Pet] = []
    var imageList: [UIImage] = []
    var pList: [Pet]!
    var iList: [UIImage]!
    let textCellIdentifier = "PetCell"
    let collectionViewIdentifier = "PetCollectionViewCell"
    let profileCreationSegue = "HomeToProfileCreation"
    let petStatusSegue = "HomeToPetStatus"
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(PetCollectionViewCell.nib(), forCellWithReuseIdentifier: collectionViewIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchPets()
    }
    
    func fetchPets() {
        print("in fetch pet")
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
                   let petDescription = petData["petDescription"] as? String,
                   let imageData = petData["petImage"] as? String,
                   let meals = petData["meals"] as? Float,
                   let amount = petData["mealAmount"] as? Float,
                   let water = petData["water"] as? Float,
                   let playtime = petData["playtime"] as? Float,
                   let petID = petData["petID"] as? String,
                   let birthdayTimestamp = petData["birthday"] as? Timestamp {
                    
                    let bDay = birthdayTimestamp.dateValue()
                    
                    let pet = Pet(petName: petName,
                                  breedName: breedName,
                                  neutered: neutered,
                                  age: age,
                                  weight: weight,
                                  gender: gender,
                                  petDescription: petDescription,
                                  imageData: imageData,
                                  mealsPerDay: meals,
                                  amountPerMeal: amount,
                                  waterNeeded: water,
                                  playtimeNeeded: playtime,
                                  petID: petID,
                                  bDay: bDay)
                    self.petList.append(pet)
                    print("pet added")
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
        
        storageManager.retrieveImage(filePath: petList[row].imageData) { image in
            if image != nil {
                cell.petImage.image = image
                self.imageList.append(image!)
            } else {
                cell.petImage.image = UIImage(named: "Petpanion_iconV1")
                self.imageList.append(UIImage(named: "Petpanion_iconV1")!)
            }
        }
        cell.petImage.layer.cornerRadius = 30
        cell.petName.text = petList[row].petName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get the selected pet from your petList
        let selectedPet = petList[indexPath.row]
        
        // Perform the segue to the next view controller (PetStatusViewController)
        performSegue(withIdentifier: petStatusSegue, sender: selectedPet)
    }

    
    // Set up segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profileCreationSegue,
           let petCreationVC = segue.destination as? ProfileCreationViewController {
            petCreationVC.status = "creation"
            petCreationVC.delegate = self // pointer back to main VC
        }
        
        if segue.identifier == petStatusSegue,
           let destination = segue.destination as? PetStatusViewController,
        // Pass the operator type selected into next VC
            let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            destination.petIndex = selectedIndexPath.row
            destination.petList = petList
            destination.imageList = imageList
            destination.delegate = self
        }
    }
    
    func addPet(pet: Pet) {
        let newIndex = petList.count
        petList.append(pet)
        
        // Insert the new item at the end of the collection view
        let indexPath = IndexPath(item: newIndex, section: 0)
        collectionView.insertItems(at: [indexPath])
    }
    
    func updatePet(pet: Pet, petInd: Int,pList: [Pet], iList: [UIImage]) {
        // Find the pet in the list and update its information
        print("im in main update pet")
        self.petList = pList
        self.imageList = iList
        collectionView.reloadData()
    }

}
