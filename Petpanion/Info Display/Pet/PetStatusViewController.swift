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
    
    @IBOutlet weak var optionStackView: UIStackView!    
    var currentPosition = 0
    
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
    
    @IBAction func foodPressed(_ sender: Any) {
        changeViewAnimation(position: 0)
    }
    
    @IBAction func waterPressed(_ sender: Any) {
        changeViewAnimation(position: 1)
    }
    
    @IBAction func moodPressed(_ sender: Any) {
        changeViewAnimation(position: 2)
    }
    
    @IBAction func playtimePressed(_ sender: Any) {
        changeViewAnimation(position: 3)
    }
    
    func changeViewAnimation(position: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let direction = currentPosition - position
        
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.optionStackView.center.x += CGFloat((screenWidth * CGFloat(direction)))
            },
            completion: { finish in
                self.currentPosition = position
            })
    }
}