//
//  userNew.swift
//  CodableAnhCoreData
//
//  Created by AnhTu on 12/11/18.
//  Copyright © 2018 AnhTu. All rights reserved.
//

import UIKit
import CoreData

class Users: NSManagedObject, Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case address
        case username
        case job
    }
    
    @NSManaged var id: String?
    @NSManaged var username: String?
    @NSManaged var address: String?
    @NSManaged var job: String?
    
    required convenience init(from decoder: Decoder) throws {
        guard let keyObjectContext = CodingUserInfoKey.managedObjectContext,
            let context = decoder.userInfo[keyObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: usersEntityName, in: context) else {
                fatalError("Failed to decode User")
        }

        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.job = try container.decodeIfPresent(String.self, forKey: .job)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(address, forKey: .address)
        try container.encode(job, forKey: .job)
        try container.encode(username, forKey: .username)
    }
    
    func saveUserDefault() {
        guard let data = try? PropertyListEncoder().encode(self) else {
            return
        }
        UserDefaults.standard.set(data, forKey: "key_Users")
    }
    
    static func loadUserDefault() -> Users? {
        guard let data = UserDefaults.standard.object(forKey: "key_Users") as? Data else {
            return nil
        }
        let user = try? PropertyListDecoder().decode(Users.self, from: data)
        return user
    }
    
}
