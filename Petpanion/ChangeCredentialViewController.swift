//
//  ChangeCredentialViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth

class ChangeCredentialViewController: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func changePasswordTapped(_ sender: UIButton) {
        guard let currentPassword = currentPasswordTextField.text, !currentPassword.isEmpty,
              let newPassword = newPasswordTextField.text, !newPassword.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }

        // Check if new passwords match
        guard newPassword == confirmPassword else {
            showAlert(message: "New passwords do not match.")
            return
        }

        // Re-authenticate the user
        reauthenticateUser(currentPassword: currentPassword, newPassword: newPassword)
    }

    private func reauthenticateUser(currentPassword: String, newPassword: String) {
        guard let user = Auth.auth().currentUser, let email = user.email else { return }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        user.reauthenticate(with: credential) { [weak self] result, error in
            if let error = error {
                self?.showAlert(message: "Re-authentication failed: \(error.localizedDescription)")
                return
            }

            // Successfully re-authenticated, proceed to update the password
            self?.updatePassword(newPassword: newPassword)
        }
    }

    private func updatePassword(newPassword: String) {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { [weak self] error in
            if let error = error {
                self?.showAlert(message: "Password update failed: \(error.localizedDescription)")
            } else {
                self?.showAlert(message: "Password updated successfully!")
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
