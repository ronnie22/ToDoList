//
//  ToDoItemModel.swift
//  ToDoList
//
//  Created by Raunak Sinha on 07/06/19.
//  Copyright © 2019 Raunak Sinha. All rights reserved.
//

import Foundation
import RealmSwift


public class LocalDatabaseManager{
    static var realm: Realm? {
        get {
            do {
                let realm = try Realm()
                return realm
            }catch {
                return nil
            }
        }
    }
}

class Task: Object {
    
    @objc dynamic var id = 0
    
    override static func primaryKey() -> String {
        return "id"
    }
    @objc dynamic var title = ""
    @objc dynamic var details = ""
    @objc dynamic var startigDate = NSDate()
    @objc dynamic var completionDate = NSDate()
    @objc dynamic var isCompleted = false
    
}
/*
 struct ToDoItems {
 var title: String
 var details: String
 var startigDate: Date
 var completionDate: Date
 var isCompleted: Bool
 
 init(title: String,details: String,completionDate: Date) {
 self.title = title
 self.details = details
 self.completionDate = completionDate
 self.startigDate = Date()
 self.isCompleted = false
 }
 }
 */
