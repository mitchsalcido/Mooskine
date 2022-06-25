//
//  ListDataSource.swift
//  Mooskine
//
//  Created by Mitchell Salcido on 6/24/22.
//  Copyright © 2022 Udacity. All rights reserved.
//

import UIKit
import CoreData

class ListDataSource<ObjectType:NSManagedObject, CellType: UITableViewCell>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    let viewContext:NSManagedObjectContext
    let fetchRequest:NSFetchRequest<ObjectType>
    let tableView:UITableView
    let cellReuseID: String
    let cellConfigurationCompletion:(CellType, ObjectType) -> Void
    
    var fetchedResultsController:NSFetchedResultsController<ObjectType>!
    var deleteManagedObjectHandler:((Int) -> Void)!
    
    init(viewContext:NSManagedObjectContext, fetchRequest:NSFetchRequest<ObjectType>, tableView:UITableView, cellReuseID: String, cellConfigurationCompletion: @escaping (CellType, ObjectType) -> Void) {
        
        self.viewContext = viewContext
        self.fetchRequest = fetchRequest
        self.tableView = tableView
        self.cellReuseID = cellReuseID
        self.cellConfigurationCompletion = cellConfigurationCompletion
        
        super.init()
        
        self.setupFetchedResultsController()
    }
    
    func setupFetchedResultsController() {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unable to perform fetch: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! CellType
        let managedObject = fetchedResultsController.object(at: indexPath)
        cellConfigurationCompletion(cell, managedObject)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        deleteManagedObject(indexPath: indexPath)
    }
    
    // MARK: - FetchedResultsController Delegate Functions
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            break
        }
    }
    
    // MARK: - Add/Delete Managed Objects, Return Managed Object
    func setEditing(editing: Bool) {
        print("ListDataSource: setEditing")
        tableView.setEditing(editing, animated: true)
    }
    
    func addNewManagedObject(completion:(ObjectType) -> Void) {
        setEditing(editing: false)
        let newManagedObject = ObjectType(context: viewContext)
        completion(newManagedObject)
        if let _ = try? viewContext.save() {}
    }
    
    func deleteManagedObject(indexPath: IndexPath) {
        let managedObjectToDelete = fetchedResultsController.object(at: indexPath)
        viewContext.delete(managedObjectToDelete)
        if let _ = try? viewContext.save(), let count = fetchedResultsController.sections?[0].numberOfObjects {

            deleteManagedObjectHandler(count)
        }
    }
    
    func managedObject(indexPath: IndexPath) -> ObjectType {
        return fetchedResultsController.object(at: indexPath)
    }
}
