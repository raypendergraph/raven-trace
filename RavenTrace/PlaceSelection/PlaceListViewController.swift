//
//  PlaceListViewController.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/27/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import CoreLocation

class PlaceListViewController: UITableViewController {
    static let PlaceCellId = String(describing: type(of: UITableViewCell.self))
    let disposeBag = DisposeBag()
    let resultsTableController = ResultsTableController(style: .grouped)
    
    lazy var geocoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    lazy var searchController: UISearchController? = { [weak self] in
        guard let `self` = self else { return nil }
        let sc = UISearchController(searchResultsController: self.resultsTableController)
        sc.searchResultsUpdater = self
        sc.searchBar.autocapitalizationType = .none
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = searchController?.searchBar
        searchController?.delegate = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.delegate = self
        
        guard let sc = searchController else { return }
        let click$ = sc.searchBar.rx.searchButtonClicked
            .scan(false, accumulator: { lastValue, _ in
                return !lastValue
            })
        .asObservable()
        
        let searchText$ = sc.searchBar.rx.text
            .map { $0 ?? "" }
            .distinctUntilChanged()
        
//        Observable.combineLatest(click$, searchText$)
//            .concatMap { [weak self] (arg) -> Observable<[CLPlacemark]> in
//                let (_, string) = arg
//                guard let `self` = self else { return Observable.empty() }
//                let latestRegion = AppDelegate.current.state.activeRegion.value
//                print("Search for \(string)")
//                return self.geocoder.rx.geocodeAddressString(addressString: string, inRegion: latestRegion)
//            }
//            .subscribe( { [weak self] placemarks in
//                self?.resultsTableController.results.accept( placemarks.map { Target(context: $0)})
//            })
//            .disposed(by: disposeBag)
//        
//

        
        definesPresentationContext = true
//        let blurEffect = UIBlurEffect.init(style: .extraLight)
//        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
//        let bluredView = UIVisualEffectView.init(effect: blurEffect)
//        bluredView.contentView.addSubview(visualEffect)
//
//        visualEffect.frame = UIScreen.main.bounds
//        bluredView.frame = UIScreen.main.bounds
        
//        view.insertSubview(bluredView, at: 0)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PlaceListViewController.PlaceCellId)
        
//        dataSource = RxTableViewSectionedAnimatedDataSource<MySection>(
//            configureCell: { ds, tv, ip, item in
//                let cell = tv.dequeueReusableCell(withIdentifier: PlaceListViewController.PlaceCellId)
//                    ?? UITableViewCell(style: .default, reuseIdentifier: PlaceListViewController.PlaceCellId)
//                cell.textLabel?.text = "Item \(item)"
//            
//                return cell
//            },
//            titleForHeaderInSection: { ds, index in
//                return ds.sectionModels[index].header
//            })
        
//        AppDelegate.current.state.trackedTargets
//            .map { [MySection(header: "Default", items: [Target]($0))] }
//            .bind(to: tableView.rx.items(dataSource: dataSource!))
//            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.view.frame
            let yComponent = UIScreen.main.bounds.height - 200
            self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        }
    }
    
    override func loadView() {
        view = UITableView(frame: CGRect.zero)
    }
    
    @objc public func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let y = view.frame.minY
        view.frame = CGRect(
            x: 0, y:
            y + translation.y,
            width: view.frame.width,
            height: view.frame.height)
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
}

extension PlaceListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        print(view.frame, tableView.contentOffset)
        if (y <= 100 && tableView.contentOffset.y == 0 && direction > 0) || (y > 100) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }

        return false
    }
}


extension PlaceListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}

extension PlaceListViewController: UISearchControllerDelegate {
    
}

extension PlaceListViewController: UISearchBarDelegate {
    
}
struct MySection {
    var header: String
    var items: [Target]
}

