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
        // Create a unique ID for each pet document
        let petID = UUID().uuidString
        
        let petData: [String: Any] = [
            "petName": pet.petName,
            "breedName": pet.breedName,
            "neutered": pet.neutered,
            "age": pet.age,
            "weight": pet.weight,
            "gender": pet.gender,
            "petDescription": pet.petDescription,
            "petImage": pet.imageData,
            "meals": pet.mealsPerDay,
            "mealAmount": pet.amountPerMeal,
            "water": pet.waterNeeded,
            "playtime": pet.playtimeNeeded,
            "petID": petID
        ]
        
        do {
            // Add the pet data to the "pets" subcollection
            let _ = try await db.collection("users").document(userId).collection("pets").document(petID).setData(petData)
        } catch {
            throw error
        }
    }
    
    // Method to add a post for a user
    func addPost(for userId: String, post: Post) async throws {
        let postData: [String: Any] = [
            "title": post.title,
            "body": post.body,
            "imageDatas": post.imageDatas
        ]
        
        do {
            // Create a unique ID for each post document
            let postID = UUID().uuidString
            
            // Add the post data to the "posts" subcollection
            let _ = try await db.collection("users").document(userId).collection("posts").document(postID).setData(postData)
        } catch {
            throw error
        }
    }
    
    
    
    
//    // Method to add a reminder for a specific pet by pet name
//    func addReminder(for userId: String, petName: String, reminder: Reminder) async throws {
//        let reminderData: [String: Any] = [
//            "title": reminder.title,
//            "time": reminder.time,
//            "isCompleted": reminder.isCompleted,
//            "petName": petName
//        ]
//        
//        do {
//            let reminderId = UUID().uuidString // Unique ID for each reminder
//            let _ = try await db.collection("users").document(userId).collection("pets").document(petName).collection("reminders").document(reminderId).setData(reminderData)
//        } catch {
//            throw error
//        }
//    }
//    
//    // Method to fetch reminders for a specific pet
//    func fetchReminders(for userId: String, petId: String) async throws -> [Reminder] {
//        let snapshot = try await db.collection("users").document(userId).collection("pets").document(petId).collection("reminders").getDocuments()
//        return snapshot.documents.compactMap { doc -> Reminder? in
//            let data = doc.data()
//            guard let title = data["title"] as? String,
//                  let time = (data["time"] as? Timestamp)?.dateValue(),
//                  let isCompleted = data["isCompleted"] as? Bool else { return nil }
//            
//            return Reminder(id: doc.documentID, title: title, time: time, isCompleted: isCompleted, petId: petId, petName: data["petName"] as? String)
//        }
//    }
//    
//    // Fetch pets for a user
//    func fetchPets(for userId: String) async throws -> [Pet] {
//        let snapshot = try await db.collection("users").document(userId).collection("pets").getDocuments()
//        return snapshot.documents.compactMap { doc -> Pet? in
//            let data = doc.data()
//            guard let petName = data["petName"] as? String else { return nil }
//            return Pet(id: doc.documentID, name: petName)
//        }
//    }
//
//    
//    // Method to toggle reminder completion status
//    func toggleReminderCompletion(for userId: String, petId: String, reminder: Reminder) async throws {
//        do {
//            let reminderRef = db.collection("users").document(userId).collection("pets").document(petId).collection("reminders").document(reminder.id)
//            try await reminderRef.updateData(["isCompleted": !reminder.isCompleted])
//        } catch {
//            throw error
//        }
//    }
}
