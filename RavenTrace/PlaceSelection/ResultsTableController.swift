//
//  ResultsTableController.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/27/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ResultsTableController: UITableViewController {
    let disposeBag = DisposeBag()
    let results = PublishRelay<[Target]>()
    override func viewDidLoad() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        results
            .flatMap { Observable.from(optional: $0) }
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                print(element)
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = element.name
                return cell
            }
            .disposed(by: disposeBag)
    }
}
