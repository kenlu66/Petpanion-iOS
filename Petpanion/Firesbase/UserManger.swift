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
            "petID": petID,
            "birthday": pet.birthdate
        ]
        
        do {
            // Add the pet data to the "pets" subcollection
            let _ = try await db.collection("users").document(userId).collection("pets").document(petID).setData(petData)
        } catch {
            throw error
        }
    }
    
    // Method to update a pet for a user
    func updatePet(for userId: String, pet: Pet) async throws {
        let petID = pet.petID // Ensure the pet has a valid petID
        
        if petID == "" {
            
                print(pet.petName)
                print(petID)
                print(pet.petName)
            
        }
        
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
            "birthday": pet.birthdate,
            "petID": petID
        ]
        
        do {
            // Update the pet data in the "pets" subcollection
            let _ = try await db.collection("users").document(userId).collection("pets").document(petID).updateData(petData)
        } catch {
            throw error
        }
    }
    
    // Method to add a post for a user
    func addPost(for userId: String, post: Post) async throws {
        let postData: [String: Any] = [
            "title": post.title,
            "body": post.body,
            "imageData": post.imageData
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
    
    // Method to add a reminder for a user
    func addReminder(for userId: String, reminder: MyReminder) async throws {
        let reminderID = UUID().uuidString
        let reminderData: [String: Any] = [
            "title": reminder.title,
            "body": reminder.body,
            "date": reminder.date ?? Date(), // Store the date or a default
            "tag": reminder.tag,
            "location": reminder.location,
            "flagged": reminder.flagged,
            "completed": reminder.completed,
            "reminderID": reminderID
        ]
        
        do {
            let _ = try await db.collection("users").document(userId).collection("reminders").document(reminderID).setData(reminderData)
        } catch {
            throw error
        }
    }
    
    // Method to fetch reminders for a user
    func fetchReminders(for userId: String) async throws -> [MyReminder] {
        var reminders = [MyReminder]()
        
        let snapshot = try await db.collection("users").document(userId).collection("reminders").getDocuments()
        
        for document in snapshot.documents {
            let data = document.data()
            let reminder = MyReminder(
                identifier: data["reminderID"] as? String ?? "",
                title: data["title"] as? String ?? "",
                body: data["body"] as? String ?? "",
                date: ((data["date"] as? Timestamp)?.dateValue())!,
                tag: data["tag"] as? String ?? "",
                location: data["location"] as? String ?? "",
                flagged: data["flagged"] as? Bool ?? false,
                completed: data["completed"] as? Bool ?? false
            )
            reminders.append(reminder)
        }
        
        return reminders
    }
    
}
