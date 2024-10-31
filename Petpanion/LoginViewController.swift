//
//  LoginViewController.swift
//  Petpanion
//
//  Created by Mengying Jin on 10/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passswordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    let toHomeSegue = "LoginToHome"
    let toRegisterSegue = "LoginToRegister"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 27
        loginButton.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = 27
        signUpButton.layer.masksToBounds = true
        
        errorMessage.text = ""
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let userEmail = emailField.text else { return }
        guard let password = passswordField.text else { return }
                
        Auth.auth().signIn(withEmail: userEmail, password: password) { (authResult, error) in
            if let error = error as NSError? {
                self.errorMessage.text =  "\(error.localizedDescription)"
            } else {
                self.performSegue(withIdentifier: self.toHomeSegue, sender: self)
            }
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        self.performSegue(withIdentifier: toRegisterSegue, sender: self)
    }
}
