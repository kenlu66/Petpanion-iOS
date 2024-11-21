//
//  UserInfoViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseStorage

class UserInfoViewController: UIViewController {
    let storageManager = StorageManager()

    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func saveImage(_ sender: Any) {
        let photoID = UUID().uuidString
        let path = "2022-08-27-09-46-48_0.png"
        storageManager.storeImage(filePath: path, image: image.image!)
    }
    
}
