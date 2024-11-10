//
//  PetStatusViewController.swift
//  Petpanion
//
//  Created by Mengying Jin on 11/9/24.
//

import UIKit

class PetStatusViewController: UIViewController {

    @IBOutlet weak var foodOption: UIButton!
    
    @IBOutlet weak var waterOption: UIButton!
    
    @IBOutlet weak var moodOption: UIButton!
    
    @IBOutlet weak var playtimeOption: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        foodOption.layer.shadowOpacity = 0.25
        foodOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        waterOption.layer.shadowOpacity = 0.25
        waterOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        moodOption.layer.shadowOpacity = 0.25
        moodOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        playtimeOption.layer.shadowOpacity = 0.25
        playtimeOption.layer.shadowOffset = CGSize(width: 2, height: 2)
        
//        medicalButton.layer.shadowOpacity = 0.25
//        medicalButton.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    

}
