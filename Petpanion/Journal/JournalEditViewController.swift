//
//  JournalEditViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import PhotosUI
import FirebaseAuth

class JournalEditViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
    // variables
    let cellIdentifier = "journalImageCollectionViewCell"
    let userManager = UserManager()
    let storageManager = StorageManager()
    var delegate: UIViewController!
    var status: String!
    var titleField: String!
    var bodyField: String!
    var postID: String!
    var imagePath: String!
    var image: UIImage!
    var posts: [Post]!
    var postIndex: Int!
    
    // for image
    var imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    var imageChanged = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        bodyTextView.isEditable = true
        
        if status == "update" {
            fillInFields()
        }
    }
    
    func fillInFields() {
        imageView.image = image
        titleTextField.text = titleField
        bodyTextView.text = bodyField
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
 
    @IBAction func didTapSave(_ sender: Any) {
        // Create a unique ID for each post document
        let newID = UUID().uuidString
        
        guard let postTitle = titleTextField.text, !postTitle.isEmpty,
              let postBody = bodyTextView.text, !postBody.isEmpty else {
                   // Handle empty fields or invalid input here
                    let alert = UIAlertController(title: "Invalid Fields", message: "Please fill in both title and body section", preferredStyle: .alert)
                    
                    // Confirm action
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                   return
               }
        
        var path = ""
        
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("user not authenticated")
            return
        }
        
        // update images if needed
        if (status == "update") {
            if (imageChanged == 1) {
                storageManager.deleteImage(filePath: imagePath)
                if let image = imageView.image {
                    let imageID = UUID().uuidString
                    path = "JournalImages/\(imageID).jpeg"
                    storageManager.storeImage(filePath: path, image: image)
                }
            } else {
                path = imagePath
            }
        } else if (status == "NewPost") {
            postID = newID
            if let image = imageView.image {
                let imageID = UUID().uuidString
                path = "JournalImages/\(imageID).jpeg"
                storageManager.storeImage(filePath: path, image: image)
            }
        }
        
        let newPost = Post(
            title: postTitle,
            body: postBody,
            imageData: path,
            postID: postID
        )

        // Add the post to Firestore
        Task {
            do {
                if status == "NewPost" {
                    try await userManager.addPost(for: userId, post: newPost, docID: postID)
                    print("New post submitted successfully!")
                    
                    // add to post list
                    if let otherVC = delegate as? updatePostList {
                        otherVC.updatePosts(post: newPost)
                    }
                    // alert user and dismiss vc
                    let alert = UIAlertController(title: "Journal Saved", message: "Navigating back now", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in self.navigationController?.popViewController(animated: true) }))
                    present(alert, animated: true, completion: nil)
                    
                } else if status == "update" {
                    // update post list
                    try await userManager.updatePost(for: userId, post: newPost)
                    
                    if let otherVC = delegate as? updatePostList {
                        self.posts[self.postIndex] = newPost
                        otherVC.editPost(posts: posts)
                    }
                    // alert user and dismiss vc
                    let alert = UIAlertController(title: "Journal Updated", message: "Navigating back now", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in self.navigationController?.popViewController(animated: true) }))
                    
                    present(alert, animated: true, completion: nil)
                    
                }
            } catch {
                print("Error adding post: \(error.localizedDescription)")
            }
        }
    }
    
    // ask permission
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("Access for photo library granted")
        } else {
            print("Access for photo library not granted")
        }
    }
    
    // action for add image button
    @IBAction func didTapAddImage(_ sender: Any) {
        checkPermissions()
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    // select image from photo library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker.sourceType == .photoLibrary {
            imageView?.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            
            picker.dismiss(animated: true, completion: nil)
            imageChanged = 1
        }
    }
    
    // check user permission to use photo library
    func checkPermissions() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in () })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
}
