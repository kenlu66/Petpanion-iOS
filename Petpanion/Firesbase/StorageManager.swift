//
//  StorageManager.swift
//  Petpanion
//
//  Created by Mengying Jin on 11/12/24.
//

import Foundation
import FirebaseStorage
import UIKit

class StorageManager {
    
    let storageRef = Storage.storage(url:"gs://petpanion-3d3bb.firebasestorage.app").reference()
    
    func storeImage(filePath: String, image: UIImage) {
        
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            let fileRef = storageRef.child(filePath)
            fileRef.putData(imageData, metadata: nil) {
                (metadata, error) in
                if let error = error {
                    print("Failed to store image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func retrieveImage(filePath: String, completion: @escaping (UIImage?) -> Void) {
        let imageRef = storageRef.child(filePath)
        
        imageRef.getData(maxSize: 5 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Failed to retrieve image: \(error.localizedDescription)")
                completion(nil)  // Return nil in case of an error
            } else if let data = data {
                let image = UIImage(data: data)
                completion(image)  // Return the image once it's fetched
            } else {
                print("No data available or failed to convert data to image.")
                completion(nil)  // Return nil if no image data was retrieved
            }
        }
    }
    
    func deleteImage(filePath: String) {
        let fileRef = storageRef.child(filePath)
        
        fileRef.delete { error in
            if let error = error {
                // Handle error if deletion fails
                print("Error deleting file: \(error.localizedDescription)")
            } else {
                print("File successfully deleted")
            }
        }
    }
 
}
