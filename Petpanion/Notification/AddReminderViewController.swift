//
//  AddReminderViewController.swift
//  Petpanion
//
//  Created by Kan Lu on 11/7/24.
//

import UIKit
import FirebaseAuth
import MapKit

class AddReminderViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var titleField:UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet var mapView: MKMapView!
    
    var userManager = UserManager()
    
    public var completion: ((String, String, Date, String, String) -> Void)?
    
    public var existingReminder: MyReminder? // New property to hold existing data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
        bodyField.delegate = self
        tagField.delegate = self
        locationField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSaveButton))
        
        // Pre-fill fields with existing data if available (editing mode)
        if let reminder = existingReminder {
            titleField.text = reminder.title
            bodyField.text = reminder.body
            // date is updated with new edit
            tagField.text = reminder.tag
            locationField.text = reminder.location
        }
        
        // pre generate map if locationField already exists
        if let locationText = locationField.text, !locationText.isEmpty {
                    performSearch(for: locationText)
                }
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func didTapSaveButton() {
        // Check if title and body fields are filled
        guard let titleText = titleField.text, !titleText.isEmpty,
              let bodyText = bodyField.text, !bodyText.isEmpty else {
            showAlert()
            return
        }
        
        // Get values for optional fields (tag and location) - allow empty strings
        let tagText = tagField.text ?? ""
        let locationText = locationField.text ?? ""
        let targetDate = datePicker.date
        
        let newReminder = MyReminder(
            identifier: UUID().uuidString,
            title: titleText,
            body: bodyText,
            date: targetDate,
            tag: tagText,
            location: locationText,
            flagged: existingReminder?.flagged ?? false,
            completed: existingReminder?.completed ?? false
        )
        
        // Call the completion handler with the filled values
        completion?(titleText, bodyText, targetDate, tagText, locationText)
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        // Add the reminder to Firestore
        Task {
            do {
                try await userManager.addReminder(for: userId, reminder: newReminder)
            
                dismiss(animated: true)
            } catch {
                print("Error")
            }
        }
        
        
        
        // Optionally, pop or dismiss the view controller after saving
        navigationController?.popViewController(animated: true)
    }
    
    // Show an alert if title or body is empty
    private func showAlert() {
        let alert = UIAlertController(title: "Missing Information", message: "Please enter both a title and a body for the reminder.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == locationField, let searchText = textField.text, !searchText.isEmpty {
            performSearch(for: searchText)
        }
    }
    
    // Map search
    private func performSearch(for query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error searching for location: \(error)")
                return
            }
            
            guard let response = response, !response.mapItems.isEmpty else {
                print("No results found for the search query.")
                return
            }
            
            // Clear existing annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            // Add annotations for the search results
            for mapItem in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.title = mapItem.name
                if let location = mapItem.placemark.location {
                    annotation.coordinate = location.coordinate
                }
                self.mapView.addAnnotation(annotation)
            }
            
            // Zoom the map to the first result
            if let firstResult = response.mapItems.first,
               let location = firstResult.placemark.location {
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                )
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
}
