//
//  TableViewController.swift
//  RxSwiftTest
//
//  Created by Abai Kalikov on 5/27/20.
//  Copyright © 2020 Abai Kalikov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    var repositoriesViewModel: ViewModel?
    let api = APIProvider()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchController()
        viewModelBinding()
    }
    
    private func viewModelBinding() {
        repositoriesViewModel = ViewModel(APIProvider: api)
        if let repositoriesViewModel = repositoriesViewModel {
            cellConfigurationBinding(viewModel: repositoriesViewModel)
            searchBarBinding(viewModel: repositoriesViewModel)
            navigationTitleBinding(viewModel: repositoriesViewModel)
        }
    }
    
    private func cellConfigurationBinding(viewModel: ViewModel) {
        viewModel.data.drive(tableView.rx.items(cellIdentifier: "Cell")) {
            _, repository, cell in
            cell.textLabel?.text = repository.name
            cell.detailTextLabel?.text = repository.url
        }.disposed(by: disposeBag)
    }
    
    private func searchBarBinding(viewModel: ViewModel) {
        searchBar.rx.text.bind(to: viewModel.searchText).disposed(by: disposeBag)
        searchBar.rx.cancelButtonClicked.map {""}.bind(to: viewModel.searchText).disposed(by: disposeBag)
    }
    
    private func navigationTitleBinding(viewModel: ViewModel) {
//        viewModel.dataConfiguring()
        viewModel.data.asDriver()
            .map {
                "\($0.count) Repositories"
        }
        .drive(navigationItem.rx.title)
        .disposed(by: disposeBag)
    }

    private func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsCancelButton = true
        searchBar.text = "virer"
        searchBar.placeholder = "Enter user"
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = false
    }
}
