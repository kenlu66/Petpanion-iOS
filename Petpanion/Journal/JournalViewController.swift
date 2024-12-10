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
    func editPost(posts: [Post])
}

class JournalViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, updatePostList {
    
    // variables
    let db = Firestore.firestore()
    let storageManager = StorageManager()
    var postList: [Post] = []
    let collectionViewCellIdentifier = "PostCollectionViewCell"
    let collectionViewIdentifier = "JournalCollectionView"
    let postSegue = "PostSegueIdentifier"
    
    var status: String!
    var titleField = ""
    var bodyParagraph = ""
    var image = UIImage(named: "Petpanion_iconV1")
    var docID = ""
    var imagePath = ""
    var index = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionViewLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchJournalEntries()
        
        // Add long-press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        status = "NewPost"
    }
    
    // set up cells layout
    func configureCollectionViewLayout() {
            let layout = UICollectionViewFlowLayout()
            let numberOfCellsPerRow: CGFloat = 2
            let numberOfCellsPerColumn: CGFloat = 3

            // Calculate the cell width and height
            let width = collectionView.bounds.width / numberOfCellsPerRow
            let height = collectionView.bounds.height / numberOfCellsPerColumn

            layout.itemSize = CGSize(width: width, height: height)
            layout.minimumLineSpacing = 0 // No spacing between rows
            layout.minimumInteritemSpacing = 0 // No spacing between columns
            collectionView.collectionViewLayout = layout
        }
    
    // retrieve journal data from firebase
    func fetchJournalEntries() {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let postRef = db.collection("users").document(userId).collection("posts")
        
        // Retrieve posts associated with the user
        postRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error retrieving pets: \(error.localizedDescription)")
                return
            }
            
            // Process the retrieved documents
            self.postList = []
            for document in snapshot?.documents ?? [] {
                let postData = document.data()
                if let postTitle = postData["title"] as? String,
                   let postBody = postData["body"] as? String,
                   let imageData = postData["imageData"] as? String,
                   let postID = postData["document ID"] as? String {
                    
                    let post = Post(title: postTitle, body: postBody, imageData: imageData, postID: postID)
                    self.postList.append(post)
                }
            }

            // Update the view with the new data
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    // set up cell data
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellIdentifier, for: indexPath) as! PostCollectionViewCell
        let row = indexPath.row
        cell.postTitleLabel.text = postList[row].title
        
        storageManager.retrieveImage(filePath: postList[row].imageData) { image in
            if image != nil {
                cell.postImage.image = image
            } else {
                cell.postImage.image = UIImage(named: "Petpanion_iconV1")
            }
        }

        cell.postImage.layer.cornerRadius = 30
        return cell
    }
    
    // a specific cell is selected, perform segue
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get the selected pet from your petList
        let row = indexPath.row
        let selectedPost = postList[row]
        titleField = postList[row].title
        bodyParagraph = postList[row].body
        docID = postList[row].postID
        imagePath = postList[row].imageData
        index = row
        status = "update"
        
        // Get the cell for the selected indexPath
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? PostCollectionViewCell {
            // Access the image from the cell's imageView
            image = selectedCell.postImage.image
        } else {
            // In case the cell is not yet loaded or accessible
            print("Cell not found")
        }
    
        performSegue(withIdentifier: postSegue, sender: selectedPost)
    }
    
    // Set up segues to pass variables
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostSegueIdentifier",
           let postVC = segue.destination as? JournalEditViewController {
            postVC.status = status
            postVC.titleField = titleField
            postVC.bodyField = postList[index].body
            postVC.image = image
            postVC.postID = docID
            postVC.imagePath = imagePath
            postVC.posts = postList
            postVC.postIndex = index
            postVC.delegate = self // pointer back to main VC
        }
    }
    
    // add new post to list
    func updatePosts(post: Post) {
        let newIndex = postList.count
        postList.append(post)
        
        // Insert the new item at the end of the collection view
        let indexPath = IndexPath(item: newIndex, section: 0)
        collectionView.insertItems(at: [indexPath])
        collectionView.reloadData()
    }
    
    // reload view with updated posts
    func editPost(posts: [Post]) {
        self.postList = posts
        collectionView.reloadData()
    }
    
    //Long-Press Gesture Handler
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
        let alert = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
        
        // Confirm delete action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deletePost(at: indexPath)
        }))
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    // Delete Post Logic
    func deletePost(at indexPath: IndexPath) {
        let postToDelete = postList[indexPath.row]
        
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }

        storageManager.deleteImage(filePath: "\(postToDelete.imageData)")
        let postRef = db.collection("users").document(userId).collection("posts").document(postToDelete.postID)
        
        
        // Delete the post from Firestore
        postRef.delete { [weak self] error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
                return
            }
            
            // Remove the post locally after successful deletion
            self?.postList.remove(at: indexPath.row)
            self?.collectionView.deleteItems(at: [indexPath])
            print("Post deleted successfully.")
        }
    }
}
