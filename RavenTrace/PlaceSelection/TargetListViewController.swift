//
//  TargetListViewController.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/26/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxDataSources
import CoreLocation
import SwiftUI

class TargetListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBAction func addTarget(_ sender: Any) {
        present(addTargetAlertController, animated: true, completion: nil)
    }
    fileprivate lazy var fetchedDelegate: GenericTableFetchResultsController = {
        return GenericTableFetchResultsController(tableView: self.tableView, rowAnimation: .fade)
    }()
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Target> = {
        let fetchRequest: NSFetchRequest<Target> = Target.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let managedObjectContext = AppDelegate.current.persistentContainer.viewContext
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        fetchedResultsController.delegate = self.fetchedDelegate

        return fetchedResultsController
    }()
    
    fileprivate lazy var addTargetAlertController : UIAlertController = {
        let title = "Add Account"
        let message = "Add an account by scanning a QR code, importing a QR image, or entering a secret manually."
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .actionSheet)
        let search = UIAlertAction(title: "Search for target",
                                       style: .default) { [unowned self] _ in
            self.performSegue(withIdentifier: "SearchSegue", sender: self)
        }
        let enterManually = UIAlertAction(title: "Enter Manually",
                                          style: .default) { [unowned self] _ in
            self.performSegue(withIdentifier: "EnterManuallySegue",
                              sender: self)
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(search)
        alertController.addAction(enterManually)
        alertController.addAction(cancel)

        return alertController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
}

extension TargetListViewController: NSFetchedResultsControllerDelegate {
    
}
extension TargetListViewController: UITableViewDelegate {
    func tableView(_ table: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in

            // Create an action for sharing
            let target = self.fetchedResultsController.object(at: indexPath)
            let delete = UIAction(title: "Delete", image: .remove) { action in

                AppDelegate.current.persistentContainer.viewContext.delete(target)
            }

            return UIMenu(title: target.name ?? "Actions", children: [delete])
        }
    }
}

extension TargetListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let quotes = fetchedResultsController.fetchedObjects else { return 0 }
        return quotes.count
    }

    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: TrackedTargetTableViewCell.idenitifier,
                                                   for: indexPath) as? TrackedTargetTableViewCell else {
            fatalError("Unexpected Index Path")
        }

        let target = fetchedResultsController.object(at: indexPath)
        cell.setup(with: target)
        return cell
    }

}

class TrackedTargetTableViewCell : UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var orientationLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    func setup(with target: Target) {
        nameLabel?.text = target.name
        descriptionLabel?.text = "100 Main St. Somewhere, USA" //target.text
        orientationLabel?.text = "7.3mi"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class GenericTableFetchResultsController: NSObject {
    
    fileprivate var tableView: UITableView!
    fileprivate var rowAnimation: UITableView.RowAnimation!
    
    init(tableView: UITableView, rowAnimation: UITableView.RowAnimation) {
        self.tableView = tableView
        self.rowAnimation = rowAnimation
    }
}

extension GenericTableFetchResultsController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            
            DispatchQueue.main.async {
                guard let path = newIndexPath else {
                    assertionFailure("CoreData Issue: newIndexPath should be here on insert.")
                    return
                }
                
                self.tableView.insertRows(at: [path], with: self.rowAnimation)
            }
            
        case .update:
            DispatchQueue.main.async {
                guard let path = indexPath else {
                    assertionFailure("CoreData Issue: indexPath should be here on update.")
                    return
                }
                
                self.tableView.reloadRows(at: [path], with: self.rowAnimation)
            }
            
        case .move:
            DispatchQueue.main.async {
                guard let oldPath = indexPath, let newPath = newIndexPath else {
                    assertionFailure("CoreData Issue: Both indexPaths are required for a move.")
                    return
                }
                
                self.tableView.moveRow(at: oldPath, to: newPath)
            }
            
        case .delete:
            DispatchQueue.main.async {
                guard let path = indexPath else {
                    assertionFailure("CoreData Issue: indexPath should be here on delete.")
                    return
                }
                
                self.tableView.deleteRows(at: [path], with: self.rowAnimation)
            }
        @unknown default:
            fatalError()
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            DispatchQueue.main.async {
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: self.rowAnimation)
            }
            
        case .update:
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: sectionIndex), with: self.rowAnimation)
            }
            
        case .delete:
            DispatchQueue.main.async {
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: self.rowAnimation)
            }
            
        default: break
            
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tableView.endUpdates()
        }
    }
}
