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
    let medicalInfo = MedicalInfo()
    
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
            "petImage": pet.imageData,
            "meals": pet.mealsPerDay,
            "mealAmount": pet.amountPerMeal,
            "water": pet.waterNeeded,
            "playtime": pet.playtimeNeeded,
            "petID": pet.petID,
            "birthday": pet.birthdate
        ]
        
        do {
            // Add the pet data to the "pets" subcollection
            let petRef = db.collection("users").document(userId).collection("pets").document(pet.petID)
            let _ = try await petRef.setData(petData)
            
            let medicalTypes = ["Allergy", "Treatment", "Vaccine"]
            let medicalRef = petRef.collection("medical records")
            
            for type in medicalTypes {
                let docID = UUID().uuidString
                
                let data: [String: Any] = [
                    "Medical type": type,
                    "Document ID": docID,
                    "Records": []
                ]
                let _ = try await medicalRef.document(docID).setData(data)
            }
        } catch {
            throw error
        }
    }
    
    // Method to update a pet for a user
    func updatePet(for userId: String, pet: Pet) async throws {
        
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
            "petID": pet.petID
        ]
        
        do {
            // Update the pet data in the "pets" subcollection
            let _ = try await db.collection("users").document(userId).collection("pets").document(pet.petID).updateData(petData)
        } catch {
            throw error
        }
    }
    
    func updateMedicalRecord(for userId: String, records: [MedicalInfo.Record], docID: String, petID: String, type: String) async throws {
        var list: [[String: Any]] = []
            
        for record in records {
            let recordData: [String: Any] = [
                "date": record.date,
                "description": record.description,
                "location": record.location
            ]
            
            list.append(recordData)
        }
        
        do {
            try await db.collection("users").document(userId).collection("pets").document(petID).collection("medical records").document(docID).updateData(["Records": list])
        } catch {
            print("error in update medical record")
            throw error
        }
    }
    
    // Method to add a post for a user
    func addPost(for userId: String, post: Post, docID: String) async throws {
        
        let postData: [String: Any] = [
            "document ID": docID,
            "title": post.title,
            "body": post.body,
            "imageData": post.imageData
        ]
        
        do {
            
            // Add the post data to the "posts" subcollection
            let _ = try await db.collection("users").document(userId).collection("posts").document(docID).setData(postData)
        } catch {
            throw error
        }
    }
    
    func updatePost(for userId: String, post: Post) async throws {
        
        let data: [String: Any] = [
            "document ID": post.postID,
            "title": post.title,
            "body": post.body,
            "imageData": post.imageData
        ]
        print(post.postID)
        
        do {
            // Update the pet data in the "pets" subcollection
            let _ = try await db.collection("users").document(userId).collection("posts").document(post.postID).updateData(data)
        } catch {
            throw error
        }
    }
    
    // Method to add a reminder for a user
    func addReminder(for userId: String, reminder: MyReminder) async throws {

        let timestamp = Timestamp(date: reminder.date)
        let reminderData: [String: Any] = [
            "title": reminder.title,
            "body": reminder.body,
            "date": timestamp,
            "tag": reminder.tag,
            "location": reminder.location,
            "flagged": reminder.flagged,
            "completed": reminder.completed,
            "reminderID": reminder.identifier
        ]
        
        do {
            let _ = try await db.collection("users").document(userId).collection("reminders").document(reminder.identifier).setData(reminderData)
        } catch {
            print("error")
            throw error
        }
    }
    
//    // Method to fetch reminders for a user
//    func fetchReminders(for userId: String) async throws -> [MyReminder] {
//        var reminders: [MyReminder] = []
//        
//        let snapshot = try await db.collection("users").document(userId).collection("reminders").getDocuments()
//        
//        for document in snapshot.documents {
//            let data = document.data()
//            let reminder = MyReminder(
//                identifier: data["reminderID"] as? String ?? "",
//                title: data["title"] as? String ?? "",
//                body: data["body"] as? String ?? "",
//                date: ((data["date"] as? Timestamp)?.dateValue())!,
//                tag: data["tag"] as? String ?? "",
//                location: data["location"] as? String ?? "",
//                flagged: data["flagged"] as? Bool ?? false,
//                completed: data["completed"] as? Bool ?? false
//            )
//            reminders.append(reminder)
//            print(reminder)
//        }
//        
//        return reminders
//    }
    
}
