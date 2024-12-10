//
//  LaunchViewController.swift
//  Petpanion
//
//  Created by Kan Lu on 11/1/24.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set an animation to transition to the login page
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.view.alpha = 0
        }, completion: { _ in
            self.goToLogin()
        })

    }
    
    func goToLogin() {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: false, completion: nil)
            } else {
                print("LoginViewController could not be instantiated. Check the storyboard ID.")
            }
        }

}
