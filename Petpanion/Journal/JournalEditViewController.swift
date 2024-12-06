//
//  JournalEditViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import PhotosUI
import FirebaseAuth

//class JournalEditViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PHPickerViewControllerDelegate, UITextFieldDelegate {
class JournalEditViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    

    // variables
//    var selectedImage = [UIImage]()
    let cellIdentifier = "journalImageCollectionViewCell"
    let userManager = UserManager()
    let storageManager = StorageManager()
    var delegate: UIViewController!
    
    // for image
    var imagePickerController = UIImagePickerController()

//    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        bodyTextView.isEditable = true

//        collectionView.dataSource = self
//        collectionView.delegate = self
    }
    
    // MARK: - Keyboard Dismiss
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//    override func viewDidLayoutSubviews() {
//        super .viewDidLayoutSubviews()
//        
////        let layout = UICollectionViewFlowLayout()
////        let containerWidth = collectionView.bounds.width
////        let cellSize = (containerWidth - 45) / 10
//        
////        layout.scrollDirection = .horizontal
////        layout.itemSize = CGSize(width: 80, height: 80)
////        layout.minimumInteritemSpacing = 5
////        layout.minimumLineSpacing = 10
////        layout.sectionInset = UIEdgeInsets/*(top: 0, left: 0, bottom: 0, right: 0)*/
////        collectionView.collectionViewLayout = layout
//    }
    
    @IBAction func didTapSave(_ sender: Any) {
        guard let postTitle = titleTextField.text, !postTitle.isEmpty,
              let postBody = bodyTextView.text, !postBody.isEmpty else {
                   // Handle empty fields or invalid input here
                   print("Please fill in all fields correctly.")
                   return
               }
        
        // MARK: - Example How I stored pet photos: edit version to tailor journal
        var path = ""
        
        if let image = imageView.image {
            let imageID = UUID().uuidString
            path = "JournalImages/\(imageID).jpeg"
            storageManager.storeImage(filePath: path, image: image)
        }
        let newPost = Post(
            title: postTitle,
            body: postBody,
            imageData: path
        )
        
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("user not authenticated")
            return
        }

        // Add the post to Firestore
        Task {
            do {
                try await userManager.addPost(for: userId, post: newPost)
                print("New post submitted successfully!")
                
                // Notify delegate if needed
                if let otherVC = delegate as? updatePostList {
                    otherVC.updatePosts(post: newPost)
                }
            } catch {
                print("Error adding post: \(error.localizedDescription)")
            }
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("Access for photo library granted")
        } else {
            print("Access for photo library not granted")
        }
    }
    
    func convertImage(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return nil}
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
    
//    func convertImages(images: [UIImage]) -> [String]? {
//        var convertedImages = [String]()
//        for image in images {
//            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return nil }
//            convertedImages.append(imageData.base64EncodedString(options: .lineLength64Characters))
//        }
//        return convertedImages
//    }
    
    func convertDataToImage(imageData: String) -> UIImage? {
        if let data = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    @IBAction func didTapAddImage(_ sender: Any) {
//        var configuration = PHPickerConfiguration()
//        configuration.selectionLimit = 1
//        configuration.filter = .images
//        
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = self
//        present(picker, animated: true, completion: nil)
        checkPermissions()
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // TODO: when picker is camera
        if picker.sourceType == .photoLibrary {
            imageView?.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func checkPermissions() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in () })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
//    // PHPickerViewController Delegate
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true, completion: nil)
//        
//        for result in results {
//            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//                if let image = image as? UIImage{
//                    DispatchQueue.main.async {
//                        self?.selectedImages.append(image)
//                        self?.collectionView.reloadData()
//                    }
//                }
//            }
//        }
//    }
    
//    // Collection View DataSource and Delegate
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return selectedImages.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalImageCollectionViewCell", for: indexPath)
//        
//        let imageView = UIImageView(image: selectedImages[indexPath.item])
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 8
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        cell.contentView.addSubview(imageView)
//        
//        NSLayoutConstraint.activate([
//            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
//            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
//            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
//        ])
//        
//        return cell
//    }
}
