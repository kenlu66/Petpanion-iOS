//
//  MedicalRecordCreationVC.swift
//  Petpanion
//
//  Created by Mengying Jin on 11/13/24.
//

import UIKit
import FirebaseAuth
import MapKit

class MedicalRecordCreationVC: UIViewController, UITextFieldDelegate {

    // variables
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var currentType: String!
    var delegate: UIViewController!
    var docID: String!
    var medicalInfo = MedicalInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateField.delegate = self
        descriptionField.delegate = self
        locationField.delegate = self

        // Trigger map search if locationField has a value
        if let locationText = locationField.text, !locationText.isEmpty {
            performSearch(for: locationText)
        }
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
    
    // Perform Map Search
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
        
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
 
    // Create a new record based on the currentType
    @IBAction func submitPressed(_ sender: Any) {
        guard let date = dateField.text,
              let description = descriptionField.text,
              let location = locationField.text else { return }
        
        var newRecord: MedicalInfo.Record
        
        switch currentType {
        case "Allergy":
            newRecord = MedicalInfo.Record(description: description, date: date, location: location)
            let allergyVC = delegate as! addRecord
            allergyVC.addRecord(newRecord: newRecord)
            
        case "Vaccine":
            newRecord = MedicalInfo.Record(description: description, date: date, location: location)
            let vaccineVC = delegate as! addVaccine
            vaccineVC.addRecord(newRecord: newRecord)
            
        case "Treatment":
            newRecord = MedicalInfo.Record(description: description, date: date, location: location)
            let treatmentVC = delegate as! addTreatment
            treatmentVC.addRecord(newRecord: newRecord)
            
        default:
            print("Invalid record type")
            return
        }
    }
}
