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
        
        cell.textLabel?.text = """
        \(reminder.title)
        \(reminder.body)
        \(dateString)
        """
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    @IBAction func didTapAdd() {
        // Show add view controller
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "add") as? AddReminderViewController else {
            return
        }
        
        vc.title = "New Reminder"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { title, body, date in
            // Handle the reminder creation
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let new = MyReminder(identifier: "id_\(title)", title: title, date: date, body: body)
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

