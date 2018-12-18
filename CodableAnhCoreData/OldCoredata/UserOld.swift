//
//  UserOld.swift
//  CodableAnhCoreData
//
//  Created by AnhTu on 12/11/18.
//  Copyright © 2018 AnhTu. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class UserOld: NSObject, NSCoding {
    
    var id: String?
    var username: String?
    var address: String?
    var job: String?
    
    override init() {
        super.init()
    }
    
    init(dic: [String: Any]) {
        super.init()
        self.id = dic["id"] as? String
        self.username = dic["username"] as? String
        self.job = dic["job"] as? String
        self.address = dic["address"] as? String
    }

    init(managerObj: NSManagedObject) {
        super.init()
        self.id = managerObj.value(forKey: "id") as? String
        self.username = managerObj.value(forKey: "username") as? String
        self.job = managerObj.value(forKey: "job") as? String
        self.address = managerObj.value(forKey: "address") as? String
    }
    
    func saveToStorage() {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        do {
            let entity = NSEntityDescription.entity(forEntityName: usersEntityName, in: context)
            let newUser = NSManagedObject(entity: entity!, insertInto: context)
            newUser.setValue(self.id, forKeyPath: "id")
            newUser.setValue(self.username, forKey: "username")
            newUser.setValue(self.job, forKey: "job")
            newUser.setValue(self.address, forKey: "address")
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(username, forKey: "username")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(job, forKey: "job")
        aCoder.encode(id, forKey: "id")    }
    
    required init?(coder aDecoder: NSCoder) {
        username = aDecoder.decodeObject(forKey: "username") as? String
        address = aDecoder.decodeObject(forKey: "address") as? String
        job = aDecoder.decodeObject(forKey: "job") as? String
        id = aDecoder.decodeObject(forKey: "id") as? String
    }
    
    func saveUserDefault() {
        NSKeyedArchiver.setClassName("UserOld", for: UserOld.self)
        let encodedObj : Data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(encodedObj, forKey: "key_UserOld")
    }
    
    static func loadUserDefault() -> UserOld? {
        guard let data = UserDefaults.standard.object(forKey: "key_UserOld") as? Data else { return nil }

        NSKeyedArchiver.setClassName("UserOld", for: UserOld.self)
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? UserOld
    }
}
