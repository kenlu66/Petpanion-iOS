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
        
        // Add long-press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
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
            self.imageList = []
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
    
    func updatePet(pet: Pet, petInd: Int, pList: [Pet], iList: [UIImage]) {
        // Find the pet in the list and update its information
        self.petList = pList
        self.imageList = iList
        collectionView.reloadData()
    }

    // Long-Press Gesture Handler
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: collectionView)
        
        // Get the index path of the cell at the pressed location
        if let indexPath = collectionView.indexPathForItem(at: point) {
            showDeleteConfirmation(for: indexPath)
        }
    }
    
    // Delete Confirmation Dialog
    func showDeleteConfirmation(for indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Pet", message: "Are you sure you want to delete this pet?", preferredStyle: .alert)
        
        // Confirm delete action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deletePet(at: indexPath)
        }))
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    // Delete Pet Logic
    func deletePet(at indexPath: IndexPath) {
        let petToDelete = petList[indexPath.row]
        
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        // Reference to the specific pet document and image in Firestore
        storageManager.deleteImage(filePath: "\(petToDelete.imageData)")
        let petRef = db.collection("users").document(userId).collection("pets").document(petToDelete.petID)
        
        // Delete the pet from Firestore
        petRef.delete { [weak self] error in
            if let error = error {
                print("Error deleting pet: \(error.localizedDescription)")
                return
            }
            
            // Remove the pet locally after successful deletion
            self?.petList.remove(at: indexPath.row)
            self?.imageList.remove(at: indexPath.row)
            self?.collectionView.deleteItems(at: [indexPath])
            
            print("Pet deleted successfully.")
        }
    }
}
