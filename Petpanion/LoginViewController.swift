//
//  LoginViewController.swift
//  Petpanion
//
//  Created by Mengying Jin on 10/21/24.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passswordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 27
        loginButton.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = 27
        signUpButton.layer.masksToBounds = true
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
    }
    
}
