//
//  DataController.swift
//  Mooskine
//
//  Created by Mitchell Salcido on 6/22/22.
//  Copyright © 2022 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            if let completion = completion {
                completion()
            }
            self.autosaveViewContext()
        }
    }
}

extension DataController {
    
    func autosaveViewContext(interval:TimeInterval = 30) {
        print("autosaveViewContext")
        guard interval > 0 else {
            return
        }
        if viewContext.hasChanges {
            if let _ = try? viewContext.save() {
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autosaveViewContext()
        }
    }
}
