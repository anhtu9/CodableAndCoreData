//
//  ViewController.swift
//  CodableAnhCoreData
//
//  Created by AnhTu on 12/11/18.
//  Copyright © 2018 AnhTu. All rights reserved.
//

import UIKit
import CoreData

let usersEntityName = "Users"
//let userNewEntityName = "UserNew"

class ViewController: UIViewController {
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var addNewUser: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var items = [UserOld]()
    private var selectedUser: UserOld?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        deleteButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearStorage()
        loadJsonFile()
    }
    
    func loadJsonFile() -> Void {
        if let path = Bundle.main.path(forResource: "DataJson1", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [Any] {
                    for item in jsonResult {
                        if let dic = item as? [String: Any] {
                            let user = UserOld(dic: dic)
                            user.saveToStorage()
                        }
                    }
                    loadDataFromStorage()
                }
            } catch {
                // handle error
            }
        }
    }
    
    func loadDataFromStorage() -> Void {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: usersEntityName)
        request.returnsObjectsAsFaults = false
        do {
            items.removeAll()
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let user = UserOld(managerObj: data)
                items.append(user)
            }
            tableView.reloadData()
        } catch  {
            print(error)
        }
        deleteButton.isHidden = true
    }
    
    @IBAction func onDeletePress(_ sender: Any) {
        if let user = selectedUser {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: usersEntityName)
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "id == %@", user.id!)
            do {
                let result = try context.fetch(request)
                if let first = result.first as? NSManagedObject {
                    context.delete(first)
                }
            } catch {
                
            }
        }
        userNameField.text = ""
        jobField.text = ""
        addressField.text = ""
        loadDataFromStorage()
        selectedUser = nil
    }
    
    
    @IBAction func onAddNewUserPress(_ sender: Any) {
        if let user = selectedUser {
            updateUser(user: user)
        } else {
//            let userName = userNameField.text ?? ""
//            let job = jobField.text ?? ""
//            let address = addressField.text ?? ""
//            if userName.count == 0, job.count == 0 {
//                return
//            }
//            addNewUserToStorage(userName: userName, job: job, address: address)
        }
        
        userNameField.text = ""
        jobField.text = ""
        addressField.text = ""
        loadDataFromStorage()
        selectedUser = nil
    }
    
    @IBAction func onNewModelPress(_ sender: Any) {
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "NewViewController")
        self.present(newVC!, animated: true, completion: nil)
    }
    
    private func updateUser(user: UserOld) {
        let userName = userNameField.text ?? ""
        let job = jobField.text ?? ""
        let address = addressField.text ?? ""
        if userName.count == 0, job.count == 0 {
            return
        }
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: usersEntityName)
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id == %@", user.id!)
        do {
            let result = try context.fetch(request)
            if let first = result.first as? NSManagedObject {
                first.setValue(userName, forKey: "username")
                first.setValue(job, forKey: "job")
                first.setValue(address, forKey: "address")
                try context.save()
            }
        } catch {
            
        }
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


extension ViewController: UITableViewDelegate, UITableViewDataSource {
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
        deleteButton.isHidden = false
    }
    
}

