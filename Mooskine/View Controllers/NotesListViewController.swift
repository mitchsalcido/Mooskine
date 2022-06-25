//
//  NotesListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotesListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var notebook: Notebook!
    var dataController:DataController!
    var listDataSource:ListDataSource<Note, NoteCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = notebook.name
        navigationItem.rightBarButtonItem = editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listDataSource = nil
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key:"creationDate", ascending:false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "notebook == %@", notebook)
        fetchRequest.predicate = predicate
        
        listDataSource = ListDataSource<Note, NoteCell>(viewContext: dataController.viewContext, fetchRequest: fetchRequest, tableView: tableView, cellReuseID: "NoteCell", cellConfigurationCompletion: { cell, note in
 
            let dataFormatter = DateFormatter()
            dataFormatter.dateStyle = .medium
            if let creationDate = note.creationDate {
                cell.dateLabel.text = dataFormatter.string(from: creationDate)
            }
            cell.textPreviewLabel.text = note.text
            
        })
        tableView.dataSource = listDataSource
        listDataSource.deleteManagedObjectHandler = { count in
            if count == 0 {
                self.setEditing(false, animated: true)
            }
        }
    }

    // MARK: - Actions
    @IBAction func addTapped(sender: Any) {
        addNote()
    }

    // MARK: - Adding New Note
    func addNote() {
        listDataSource.addNewManagedObject { note in
            note.notebook = notebook
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let vc = segue.destination as? NoteDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.note = listDataSource.managedObject(indexPath: indexPath)
                vc.dataController = dataController
                
                vc.onDelete = { [weak self] in
                    if let indexPath = self?.tableView.indexPathForSelectedRow {
                        self?.listDataSource.deleteManagedObject(indexPath: indexPath)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
