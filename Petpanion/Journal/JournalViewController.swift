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
        
        collectionView.register(PostCollectionViewCell.nib(), forCellWithReuseIdentifier: collectionViewCellIdentifier)
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
                   let imageData = postData["imageDatas"] as? [String] {
                    
                    let post = Post(title:postTitle, body: postBody, imageDatas: imageData)
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
        
//        if let image = convertDataToImage(imageData: postList[row].imageDatas[0]) {
////            cell.petImage.image = image
//        } else {
//            //cell.petImage.image = UIImage(named: "Petpanion_iconV1")
//        }
////        cell.petImage.layer.cornerRadius = 30
////        cell.petName.text = petList[row].petName
        return cell
    }
    
    func updatePosts(post: Post) {
        let newIndex = postList.count
        postList.append(post)
        
        // Insert the new item at the end of the collection view
        let indexPath = IndexPath(item: newIndex, section: 0)
        collectionView.insertItems(at: [indexPath])
    }
    

}
