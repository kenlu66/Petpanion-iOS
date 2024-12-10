//
//  RegisterViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {

    // variables
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    let toLoginSegue = "RegisterToLogin"
    let userManager = UserManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self

        loginButton.layer.cornerRadius = 27
        loginButton.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = 27
        signUpButton.layer.masksToBounds = true
        
        errorMessage.text = ""
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
    
    // action when sign up is pressed
    @IBAction func signUpPressed(_ sender: Any) {
        guard let userEmail = emailField.text else { return }
        guard let password = passwordField.text else { return }
                
        // Call the UserManager's signUpUser method
        Task {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: userEmail, password: password)
                try await userManager.createNewUser(user: authResult.user) // Create user in Firestore
                self.performSegue(withIdentifier: self.toLoginSegue, sender: self)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage.text = "Error signing up: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // go to login page
    @IBAction func loginPressed(_ sender: Any) {
        self.performSegue(withIdentifier: toLoginSegue, sender: self)
    }
}
