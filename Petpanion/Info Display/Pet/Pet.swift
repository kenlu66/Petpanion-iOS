//
//  Pet.swift
//  Petpanion
//
//  Created by Xin Gao on 10/23/24.
//

import Foundation
import FirebaseFirestore

class Pet {
    var petName: String
    var breedName: String
    var neutered: String
    var age: Int
    var weight: Float
    var gender: String
    var petDescription: String
    var imageData: String
    
    init(petName: String, breedName: String, neutered: String, age: Int, weight: Float, gender: String, petDescription: String, imageData: String) {
        self.petName = petName
        self.breedName = breedName
        self.neutered = neutered
        self.age = age
        self.weight = weight
        self.gender = gender
        self.petDescription = petDescription
        self.imageData = imageData
    }
}
