//
//  Pet.swift
//  Petpanion
//
//  Created by Xin Gao on 10/23/24.
//

import Foundation

class Pet {
    var petName: String
    var breedName: String
    var neutered: String
    var age: Int
    var weight: Float
    var gender: String
    var petDescription: String
    var imageData: String
    var mealsPerDay: Float
    var amountPerMeal: Float
    var waterNeeded: Float
    var playtimeNeeded: Float
    var petID: String
    var birthdate: String
    
    init(petName: String, breedName: String, neutered: String, age: Int, weight: Float, gender: String, petDescription: String, imageData: String, mealsPerDay: Float, amountPerMeal: Float, waterNeeded: Float, playtimeNeeded: Float, petID: String, bDay: String) {
        self.petName = petName
        self.breedName = breedName
        self.neutered = neutered
        self.age = age
        self.weight = weight
        self.gender = gender
        self.petDescription = petDescription
        self.imageData = imageData
        self.mealsPerDay = mealsPerDay
        self.amountPerMeal = amountPerMeal
        self.waterNeeded = waterNeeded
        self.playtimeNeeded = playtimeNeeded
        self.petID = petID
        self.birthdate = bDay
    }
}
