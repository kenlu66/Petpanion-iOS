//
//  LoginViewController.swift
//  Petpanion
//
//  Created by Mengying Jin on 10/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {

    // variables
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passswordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    let toHomeSegue = "LoginToHome"
    let toRegisterSegue = "LoginToRegister"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passswordField.delegate = self
        
        loginButton.layer.cornerRadius = 27
        loginButton.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = 27
        signUpButton.layer.masksToBounds = true
        
        errorMessage.text = ""
        
        Auth.auth().addStateDidChangeListener() {
            (auth,user) in
            if user != nil {
                self.performSegue(withIdentifier: self.toHomeSegue, sender: nil)
                self.emailField.text = nil
                self.passswordField.text = nil
            }
        }
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
    
    // action when login is pressed
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
    
    // go to sign up page
    @IBAction func signUpPressed(_ sender: Any) {
        self.performSegue(withIdentifier: toRegisterSegue, sender: self)
    }
}
