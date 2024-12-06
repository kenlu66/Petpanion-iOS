//
//  NotificationHistoryViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth
import UserNotifications
import FirebaseFirestore

class NotificationHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    var models: [MyReminder] = []
    let userManager = UserManager()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        
        // Asks for permission when page is loaded
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
        }
        
        fetchReminders()
        
    }
    
    func fetchReminders() {
        
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        let reminderRef = db.collection("users").document(userId).collection("reminders")
        
        reminderRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error retrieving pets: \(error.localizedDescription)")
                return
            }
            for document in snapshot?.documents ?? [] {
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
                self.models.append(reminder)
                print(reminder)
            }
            
            self.table.reloadData()
        }
        
    }

    // Toggle Completion Check Mark
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle the completion status
        models[indexPath.row].completed.toggle()
        
        // Reload the specific cell to update the checkmark
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        // Deselect the cell to remove the highlight effect
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let reminder = models[indexPath.row]
        

        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateString = formatter.string(from: reminder.date)
        
        // Create an NSMutableAttributedString to style the text
        let attributedText = NSMutableAttributedString()

        // Title - Bold and Larger Font
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        let titleString = NSAttributedString(string: "\(reminder.title)\n", attributes: titleAttributes)
        attributedText.append(titleString)

        // Configure the checkmark
        cell.accessoryType = reminder.completed ? .checkmark : .none
        
        // Body - Regular Font, Slightly Smaller
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.darkGray
        ]
        let bodyString = NSAttributedString(string: "\(reminder.body)\n", attributes: bodyAttributes)
        attributedText.append(bodyString)


        // Tag - Bold with a Hash Symbol and Colored Tag
        if !reminder.tag.isEmpty {
            let tagAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.systemBlue
            ]
            let tagString = NSAttributedString(string: "#\(reminder.tag)\n", attributes: tagAttributes)
            attributedText.append(tagString)
        }

        
        // Location - Regular Font, Dark Gray Color
        if !reminder.location.isEmpty {
            let locationAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.darkGray
            ]
            let locationString = NSAttributedString(string: "\(reminder.location)\n", attributes: locationAttributes)
            attributedText.append(locationString)
        }
        
        // Date - Italic Font, Light Gray Color
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 14),
            .foregroundColor: UIColor.lightGray
        ]
        let DateString = NSAttributedString(string: "\(dateString)", attributes: dateAttributes)
        attributedText.append(DateString)

        // Assign the attributed string to the cell's textLabel
        cell.textLabel?.numberOfLines = 0 // Allow multiple lines
        cell.textLabel?.attributedText = attributedText

        // Flag Icon - Add to the top right corner if flagged
        let flagIcon = UIImageView(image: UIImage(systemName: "flag.fill"))
        flagIcon.tintColor = .systemOrange
        flagIcon.translatesAutoresizingMaskIntoConstraints = false
        flagIcon.isHidden = !reminder.flagged // Show only if flagged
        
        cell.contentView.addSubview(flagIcon)
        
        // Set constraints to place the icon at the top right
        NSLayoutConstraint.activate([
            flagIcon.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            flagIcon.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
            flagIcon.widthAnchor.constraint(equalToConstant: 16),
            flagIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        return cell
    }

    // Swipe Actions for Delete and Flag
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete Action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            
            guard let self = self else { return }
                    
            // Get the reminder to delete
            let reminderToDelete = self.models[indexPath.row]
            
            // Ensure the user is authenticated
            guard let userId = Auth.auth().currentUser?.uid else {
                print("User not authenticated.")
                completionHandler(false)
                return
            }
            
            // Reference to the specific reminder document in Firestore
            let reminderRef = self.db.collection("users").document(userId).collection("reminders").document(reminderToDelete.identifier)
            
            // Remove the reminder from Firestore
            reminderRef.delete { error in
                if let error = error {
                    print("Error deleting reminder: \(error.localizedDescription)")
                    completionHandler(false)
                    return
                }
                
                // Remove the reminder locally after successful deletion
                self.models.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
        }
        deleteAction.backgroundColor = .systemRed
        
        // Edit Action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.showEditScreen(for: indexPath.row)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var reminder = models[indexPath.row]
        
        let flagAction = UIContextualAction(style: .normal, title: reminder.flagged ? "Unflag" : "Flag") { (action, view, completionHandler) in
            // Toggle the flagged status
            reminder.flagged.toggle()
            self.models[indexPath.row] = reminder
            
            // Reload the specific cell to update the flag icon
            tableView.reloadRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        flagAction.backgroundColor = .systemOrange

        return UISwipeActionsConfiguration(actions: [flagAction])
    }

    //Show Edit Screen
    func showEditScreen(for index: Int) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "add") as? AddReminderViewController else {
            return
        }
        
        let reminder = models[index]
        
        vc.title = "Edit Reminder"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.existingReminder = reminder
        vc.completion = { [weak self] title, body, date, tag, location in
            DispatchQueue.main.async {
                self?.models[index] = MyReminder(identifier: reminder.identifier, title: title, body: body, date: date, tag: tag, location: location, flagged: reminder.flagged, completed: reminder.completed)
                self?.table.reloadData()
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // - + New Reminder Btn tapped
    @IBAction func didTapAdd() {
        
        // Show add view controller
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "add") as? AddReminderViewController else {
            return
        }
        
        vc.title = "New Reminder"
        vc.navigationItem.largeTitleDisplayMode = .never
        
        vc.completion = { title, body, date, tag, location in
            // Handle the reminder creation
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let new = MyReminder(identifier: "id_\(title)", title: title, body: body, date: date, tag: tag, location: location, flagged: false, completed: false)
                self.models.append(new)
                self.table.reloadData()
                
                let content = UNMutableNotificationContent()
                content.title = title
                content.sound = .default
                content.body = body
                
                
                let targetDate = date
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate),
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: "some_long_id",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if error != nil {
                        print("something went wrong")
                    }
                })
    
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

