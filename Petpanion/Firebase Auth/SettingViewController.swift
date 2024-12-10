//
//  SettingViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {

    // Create an outlet for the switch
    @IBOutlet weak var themeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the saved theme preference and set the switch position
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        themeSwitch.isOn = isDarkMode

        // Apply the saved theme preference
        updateTheme(isDarkMode: isDarkMode)
    }
    
    // Action triggered when the switch is toggled
    @IBAction func themeSwitchToggled(_ sender: UISwitch) {
        let isDarkMode = sender.isOn
        // Save the user's preference
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        updateTheme(isDarkMode: isDarkMode)
    }
    
    // Function to apply the chosen theme
    func updateTheme(isDarkMode: Bool) {
        // Find the active window scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }

    // sign out action
    @IBAction func signOut(_ sender: Any) {
        do {
            // Attempt to sign out from Firebase Authentication
            try Auth.auth().signOut()
            
            navigateToSignInPage()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // Function to navigate to the Sign In page
    private func navigateToSignInPage() {
        if let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") {
            signInVC.modalPresentationStyle = .fullScreen
            present(signInVC, animated: true, completion: nil)
        }
    }
    
}
