//
//  PlaceSelectionViewController.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/27/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CoreLocation
import RxDataSources

class PlaceSelectionViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBAction func addTarget(_ sender: Any) {
        present(addTargetAlertController, animated: true, completion: nil)
    }
    private lazy var addTargetAlertController = makeAddTargetAlertController()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sections: [MultipleSectionModel] = [
            .CurrentlyTrackedSection(title: "Currently Tracking",
                                     items: [.TrackedSectionItem(title: "Cool")]),
            .RecentlyTrackedSection(title: "Popular",
                                    items: [.RecentSectionItem(title: "On")]),
            .OtherSection(title: "The Rest",
                          items: [.OtherSectionItem(title: "1")])
        ]
        
        let dataSource = PlaceSelectionViewController.dataSource()
        
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func makeAddTargetAlertController() -> UIAlertController {
        let title = "Add Account"
        let message = "Add an account by scanning a QR code, importing a QR image, or entering a secret manually."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let scanQRCode = UIAlertAction(title: "Search for target", style: .default) { [unowned self] _ in
            self.performSegue(withIdentifier: "SearchSegue", sender: self)
        }
        let enterManually = UIAlertAction(title: "Enter Manually", style: .default) { [unowned self] _ in
            self.performSegue(withIdentifier: "EnterManuallySegue", sender: self)
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(scanQRCode)
        alertController.addAction(enterManually)
        alertController.addAction(cancel)

        return alertController
    }
}


extension PlaceSelectionViewController {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<MultipleSectionModel> {
    return RxTableViewSectionedReloadDataSource<MultipleSectionModel>(
        configureCell: { ds, tableView, idxPath, item in
            switch ds[idxPath] {
            case let .TrackedSectionItem(title):
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TrackedTableViewCell",
                                                            for: idxPath) as? TrackedTableViewCell {
                    cell.configure(title: title)
                                    return cell
                }
                
            case let .RecentSectionItem(title):
                if let cell = tableView.dequeueReusableCell(withIdentifier: "RecentTableViewCell",
                                                            for: idxPath) as? RecentTableViewCell {
                    cell.configure(title: title)
                    return cell
                }
                
            case let .OtherSectionItem(title):
                if let cell = tableView.dequeueReusableCell(withIdentifier: "OtherTableViewCell",
                                                            for: idxPath) as? OtherTableViewCell {
                    cell.configure(title: title)
                    return cell
                }
            }
            //TODO
            return UITableViewCell()
        },
        titleForHeaderInSection: { dataSource, index in
            //let section = dataSource[index]
            return "TODO"
        }
    )
}
}
enum MultipleSectionModel : SectionModelType{
    typealias Item = SectionItem
    
    case CurrentlyTrackedSection(title: String, items: [SectionItem])
    case RecentlyTrackedSection(title: String, items: [SectionItem])
    case OtherSection(title: String, items: [SectionItem])

    var items: [SectionItem] {
        switch  self {
        case .CurrentlyTrackedSection(title: _, items: let items):
            return items.map { $0 }
        case .RecentlyTrackedSection(title: _, items: let items):
            return items.map { $0 }
        case .OtherSection(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: MultipleSectionModel, items: [Item]) {
        switch original {
        case let .CurrentlyTrackedSection(title: title, items: _):
            self = .CurrentlyTrackedSection(title: title, items: items)
        case let .RecentlyTrackedSection(title, _):
            self = .RecentlyTrackedSection(title: title, items: items)
        case let .OtherSection(title, _):
            self = .OtherSection(title: title, items: items)
        }
    }
}

enum SectionItem {
    case TrackedSectionItem(title: String)
    case RecentSectionItem(title: String)
    case OtherSectionItem(title: String)
}

class TrackedTableViewCell: UITableViewCell {
   @IBOutlet private weak var titleLabel: UILabel!

    func configure(title: String) {
        titleLabel.text = title
    }
}

class RecentTableViewCell: UITableViewCell {
   @IBOutlet private weak var titleLabel: UILabel!

    func configure(title: String) {
        titleLabel.text = title
    }
}

class OtherTableViewCell: UITableViewCell {
   @IBOutlet private weak var titleLabel: UILabel!

    func configure(title: String) {
        titleLabel.text = title
    }
}
