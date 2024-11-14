//
//  JournalViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol updatePostList {
    func updatePosts(post: Post)
}

class JournalViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, updatePostList {
    
    // variables
    let db = Firestore.firestore()
    var postList: [Post] = []
    let collectionViewCellIdentifier = "PostCollectionViewCell"
    let collectionViewIdentifier = "JournalCollectionView"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchJournalEntries()
    }
    
    func fetchJournalEntries() {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        // Reference to the pets subcollection for the authenticated user
        let postRef = db.collection("users").document(userId).collection("posts")
        
        // Retrieve posts associated with the user
        postRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error retrieving pets: \(error.localizedDescription)")
                return
            }
            
            // Process the retrieved documents
            self.postList = [] // Clear existing pet list
            for document in snapshot?.documents ?? [] {
                let postData = document.data()
                if let postTitle = postData["title"] as? String,
                   let postBody = postData["body"] as? String,
                   let imageData = postData["imageData"] as? String {
                    
                    let post = Post(title:postTitle, body: postBody, imageData: imageData)
                    self.postList.append(post)
                }
            }

            // Update the table view with the new data
            self.collectionView.reloadData()
        }
    }
    
    func convertDataToImage(imageData: String) -> UIImage? {
        if let data = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellIdentifier, for: indexPath) as! PostCollectionViewCell
        let row = indexPath.row
        cell.postTitleLabel.text = postList[row].title
        
        if let image = convertDataToImage(imageData: postList[row].imageData) {
            cell.postImage.image = image
        } else {
            cell.postImage.image = UIImage(named: "Petpanion_iconV1")
        }
        cell.postImage.layer.cornerRadius = 30
        return cell
    }
    
    // Set up segues to pizza creation view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostSegueIdentifier",
           let postVC = segue.destination as? JournalEditViewController {
            postVC.delegate = self // pointer back to main VC
        }
        
//        if segue.identifier == "HomeToPetInfo",
//           let destination = segue.destination as? PetInfoViewController,
//        // Pass the operator type selected into next VC
//            let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
//            let selectedPet = postList[selectedIndexPath.row]
//            destination.selectedPet = selectedPet
//        }
        
    }
    
    func updatePosts(post: Post) {
        let newIndex = postList.count
        postList.append(post)
        
        // Insert the new item at the end of the collection view
        let indexPath = IndexPath(item: newIndex, section: 0)
        collectionView.insertItems(at: [indexPath])
        collectionView.reloadData()
    }
    

}
