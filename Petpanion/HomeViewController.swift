//
//  HomeViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit

protocol updatePetList {
    func updatePet(pet: Pet)
}


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, updatePetList {
    
    
    var petList: [Pet] = []
    @IBOutlet weak var tableView: UITableView!
    let textCellIdentifier = "PetCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
          
        // Put pizza detail into cell
        cell.textLabel?.numberOfLines = 5 // Five lines for all information to show
        cell.textLabel?.text = petList[row].petName
        
        return cell
    }
    
    // Set up segues to pizza creation view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToProfileCreation",
           let petCreationVC = segue.destination as? ProfileCreationViewController {
            petCreationVC.delegate = self // pointer back to main VC
        }
        
        if segue.identifier == "HomeToPetInfo",
           let destination = segue.destination as? PetInfoViewController,
           // Pass the operator type selected into next VC
           let petIndex = tableView.indexPathForSelectedRow?.row {
            destination.selectedPet = petList[petIndex]
        }
    }
    
    func updatePet(pet: Pet) {
        self.petList.append(pet)
        self.tableView.reloadData()
    }
}
