//
//  NewViewController.swift
//  CodableAnhCoreData
//
//  Created by AnhTu on 12/11/18.
//  Copyright © 2018 AnhTu. All rights reserved.
//

import UIKit
import CoreData

class NewViewController: UIViewController {
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var addNewUser: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var items = [Users]()
    private var selectedUser: Users?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearStorage()
        loadJsonFile()
    }
    
    func loadJsonFile() -> Void {
        if let path = Bundle.main.path(forResource: "DataJson1", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appdelegate.persistentContainer.viewContext
                let decoder = JSONDecoder()
                decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = context
                _ = try decoder.decode([Users].self, from: jsonData)
                try context.save()
                loadDataFromStorage()
            } catch {
                print(error)
                // handle error
            }
        }
    }
    
    func loadDataFromStorage() -> Void {
        items.removeAll()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Users>(entityName: usersEntityName)
        do {
            let users = try context.fetch(fetchRequest)
            items.append(contentsOf: users)
            tableView.reloadData()
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func onAddNewUserPress(_ sender: Any) {
        if let user = selectedUser {
            updateUser(user: user)
        } else {
//            addNewUserToStorage()
        }

        userNameField.text = ""
        jobField.text = ""
        addressField.text = ""
        loadDataFromStorage()
        selectedUser = nil
    }

//    @IBAction func onDeletePress(_ sender: Any) {
//        if let user = selectedUser {
//            let appdelegate = UIApplication.shared.delegate as! AppDelegate
//            let context = appdelegate.persistentContainer.viewContext
//            let request = NSFetchRequest<NSFetchRequestResult>(entityName: usersEntityName)
//            request.returnsObjectsAsFaults = false
//            request.predicate = NSPredicate(format: "id == %i", user.id)
//            do {
//                let result = try context.fetch(request)
//                if let first = result.first as? NSManagedObject {
//                    context.delete(first)
//                }
//            } catch {
//                
//            }
//        }
//        userNameField.text = ""
//        jobField.text = ""
//        addressField.text = ""
//        loadDataFromStorage()
//        selectedUser = nil
//    }
    
    private func updateUser(user: Users) {
        let userName = userNameField.text ?? ""
        let job = jobField.text ?? ""
        let address = addressField.text ?? ""
        if userName.count == 0, job.count == 0 {
            return
        }
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let request = NSFetchRequest<Users>(entityName: usersEntityName)
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id == %@", user.id!)
        do {
            let result = try context.fetch(request)
            if let first = result.first {
                first.setValue(userName, forKey: "username")
                first.setValue(job, forKey: "job")
                first.setValue(address, forKey: "address")
                try context.save()
            }
        } catch {
            
        }
    }
    
    @IBAction func onBackPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func clearStorage() {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: usersEntityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch let error as NSError {
            print(error)
        }
    }
}
extension NewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = items[indexPath.row]
        cell.textLabel?.text = "\(user.username ?? "") - \(user.job ?? "") - \(user.address ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = items[indexPath.row]
        selectedUser = model
        userNameField.text = model.username
        jobField.text = model.job
        addressField.text = model.address
//        deleteButton.isHidden = false
    }
    
}
