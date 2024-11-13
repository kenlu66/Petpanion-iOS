//
//  NotificationHistoryViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth
import UserNotifications

class NotificationHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    var models = [MyReminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        
//        cell.textLabel?.text = """
//        \(reminder.title)
//        \(reminder.body)
//        \(dateString)
//        #\(reminder.tag)
//        \(reminder.location)
//        """
//        cell.textLabel?.numberOfLines = 0
        
        // Create an NSMutableAttributedString to style the text
        let attributedText = NSMutableAttributedString()

        // Title - Bold and Larger Font
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        let titleString = NSAttributedString(string: "\(reminder.title)\n", attributes: titleAttributes)
        attributedText.append(titleString)

        
        // Body - Regular Font, Slightly Smaller
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.darkGray
        ]
        let bodyString = NSAttributedString(string: "\(reminder.body)\n", attributes: bodyAttributes)
        attributedText.append(bodyString)


        // Tag - Bold with a Hash Symbol and Colored Tag
        let tagAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.systemBlue
        ]
        let tagString = NSAttributedString(string: "#\(reminder.tag)\n", attributes: tagAttributes)
        attributedText.append(tagString)

        
        // Location - Regular Font, Dark Gray Color
        let locationAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.darkGray
        ]
        let locationString = NSAttributedString(string: "\(reminder.location)", attributes: locationAttributes)
        attributedText.append(locationString)
        
        
        // Date - Italic Font, Light Gray Color
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 14),
            .foregroundColor: UIColor.lightGray
        ]
        let DateString = NSAttributedString(string: "\(dateString)\n", attributes: dateAttributes)
        attributedText.append(DateString)

        // Assign the attributed string to the cell's textLabel
        cell.textLabel?.numberOfLines = 0 // Allow multiple lines
        cell.textLabel?.attributedText = attributedText

        
        return cell
    }
    
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
                let new = MyReminder(identifier: "id_\(title)", title: title, body: body, date: date, tag: tag, location: location)
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
    
    @IBAction func didTapTest(_ sender: Any) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { success, error in
            if success {
                // schedule test
                self.scheduleTest()
            } else if let error = error {
                print("Error occurred")
            }
        })
    }
    
    func scheduleTest() {
        let content = UNMutableNotificationContent()
        content.title = "Hello Petpanion"
        content.sound = .default
        content.body = "My first notification in Petpanion!"
        
        let targetDate = Date().addingTimeInterval(10)
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

