//
//  NotebooksListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotebooksListViewController: UIViewController {
    /// A table view that displays a list of notebooks
    @IBOutlet weak var tableView: UITableView!

    var dataController:DataController!
    var listDataSource:ListDataSource<Notebook, NotebookCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "toolbar-cow"))
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listDataSource = nil
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        listDataSource.setEditing(editing: editing)
    }
    
    fileprivate func setupFetchedResultsController() {
     
        let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key:"creationDate", ascending:false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        listDataSource = ListDataSource<Notebook, NotebookCell>(viewContext: dataController.viewContext, fetchRequest: fetchRequest, tableView: tableView, cellReuseID: "NotebookCell") { cell, notebook in
            cell.nameLabel.text = notebook.name
            if let count = notebook.notes?.count {
                let pageString = count == 1 ? "page" : "pages"
                cell.pageCountLabel.text = "\(count) \(pageString)"
            }
        }
        tableView.dataSource = listDataSource
        listDataSource.deleteManagedObjectHandler = {count in
            if count == 0 {
                self.setEditing(false, animated: true)
                self.listDataSource.setEditing(editing: false)
            }
        }
    }

    // MARK: - Actions
    @IBAction func addTapped(sender: Any) {
        presentNewNotebookAlert()
    }

    // MARK: - Adding New Notebook
    func presentNewNotebookAlert() {
        let alert = UIAlertController(title: "New Notebook", message: "Enter a name for this notebook", preferredStyle: .alert)

        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.addNotebook(name: name)
            }
        }
        saveAction.isEnabled = false

        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }

    func addNotebook(name: String) {
        listDataSource.addNewManagedObject { notebook in
            notebook.name = name
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NotesListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.notebook = listDataSource.managedObject(indexPath: indexPath)
                vc.dataController = dataController
            }
        }
    }
}
