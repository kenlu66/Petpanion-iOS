//
//  LoginViewController.swift
//  Petpanion
//
//  Created by Mengying Jin on 10/3/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var invalidMessage: UILabel!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func LoginPressed(_ sender: Any) {
        guard let userEmail = email.text else { return }
        guard let pass = password.text else { return }
        
        Auth.auth().signIn(withEmail: userEmail, password: pass) { [self] firebaseResult, error in
            if let e = error {
                invalidMessage.text = "\(e.localizedDescription)"
            } else {
                self.performSegue(withIdentifier: "LoginToMain", sender: self)
            }
        }
    }
    
}
