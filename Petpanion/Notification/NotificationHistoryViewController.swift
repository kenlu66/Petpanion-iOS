////
////  NotificationHistoryViewController.swift
////  Petpanion
////
////  Created by Ruolin Dong on 10/18/24.
////
//
//import UIKit
//import FirebaseAuth
//
//class ReminderListViewController: UITableViewController {
//    
//    var reminders = [Reminder]()
//    var userId: String = Auth.auth().currentUser?.uid ?? ""
//    var petName: String? // Set this based on the selected pet's name
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        if let petName = petName {
//            fetchReminders(for: petName)
//        } else {
//            print("No pet selected.")
//        }
//    }
//
//    // Fetch reminders for the specified pet name
//    func fetchReminders(for petName: String) {
//        Task {
//            do {
//                reminders = try await UserManager().fetchReminders(for: userId, petId: petName)
//                tableView.reloadData()
//            } catch {
//                print("Error fetching reminders: \(error)")
//            }
//        }
//    }
//
//    // Action to open the AddReminderViewController to create a new reminder
//    @IBAction func newReminderButtonTapped(_ sender: UIBarButtonItem) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let addReminderVC = storyboard.instantiateViewController(withIdentifier: "AddReminderViewController") as? AddReminderViewController {
//            addReminderVC.modalPresentationStyle = .formSheet
//            present(addReminderVC, animated: true, completion: nil)
//        }
//    }
//
//    // MARK: - TableView Data Source
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return reminders.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath)
//        let reminder = reminders[indexPath.row]
//        let petNameText = reminder.petName != nil ? " (\(reminder.petName!))" : ""
//        cell.textLabel?.text = reminder.title + petNameText
//        cell.accessoryType = reminder.isCompleted ? .checkmark : .none
//        return cell
//    }
//
//    // Toggle completion status of a reminder
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var reminder = reminders[indexPath.row]
//        Task {
//            do {
//                try await UserManager().toggleReminderCompletion(for: userId, petId: petName ?? "", reminder: reminder)
//                reminder.isCompleted.toggle()
//                tableView.reloadRows(at: [indexPath], with: .automatic)
//            } catch {
//                print("Error toggling reminder completion: \(error)")
//            }
//        }
//    }
//}
