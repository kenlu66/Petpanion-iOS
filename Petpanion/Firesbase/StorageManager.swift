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
    
    let storage = Storage.storage()
    
    func storeImage(filePath: String, image: UIImage) {
        let storageRef = storage.reference()
        let imageData = image.jpegData(compressionQuality: 0.5)
        
        guard imageData != nil else {
            print("Error turning image into data")
            return
        }
        let fileRef = storageRef.child(filePath)
        let uploadTask = fileRef.putData(imageData!, metadata: nil) {
            (metadata, error) in
            if error != nil {
                print("Error in storing image onto storage")
            }
        }
    }
}
