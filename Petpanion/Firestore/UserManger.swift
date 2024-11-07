//
//  UserManger.swift
//  Petpanion
//
//  Created by Mengying Jin on 10/30/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class UserManager {
    
    let db = Firestore.firestore()
    
    // Method to create a new user
    func createNewUser(user: User) async throws {
        let userData: [String: Any] = [
            "user_id": user.uid,
            "email": user.email ?? "",
            "created_at": Timestamp(date: Date())
        ]
        
        do {
            // Add the user data to the "users" collection
            let _ = try await db.collection("users").document(user.uid).setData(userData)
        } catch {
            throw error
        }
    }
    
    // Method to add a pet for a user
    func addPet(for userId: String, pet: Pet) async throws {
        let petData: [String: Any] = [
            "petName": pet.petName,
            "breedName": pet.breedName,
            "neutered": pet.neutered,
            "age": pet.age,
            "weight": pet.weight,
            "gender": pet.gender,
            "petDescription": pet.petDescription,
            "petImage": pet.imageData
        ]
        
        do {
            // Create a unique ID for each pet document
            let petId = UUID().uuidString
            
            // Add the pet data to the "pets" subcollection
            let _ = try await db.collection("users").document(userId).collection("pets").document(petId).setData(petData)
        } catch {
            throw error
        }
    }
}
