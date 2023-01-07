//
//  SearchViewController.swift
//  GithubUserSearch
//
//  Created by Yuhyeon Kim on 2023/01/04.
//

import UIKit
import Combine
import SwiftUI

class SearchViewController: UIViewController {
    
    var viewModel: SearchViewModel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias Item = SearchResult
    
    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    enum Section {
        case main
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SearchViewModel(network: NetworkService(configuration: .default))
        embedSearchController()
        configureCollectionView()
        bind()
    }
    
    private func embedSearchController() {
        self.navigationItem.title = "Search"
        
        let searchContoller = UISearchController(searchResultsController: nil)
        searchContoller.hidesNavigationBarDuringPresentation = false
        searchContoller.searchBar.placeholder = "Search your Github login ID"
        searchContoller.searchResultsUpdater = self
        searchContoller.searchBar.delegate = self
        self.navigationItem.searchController = searchContoller
    }
    
    private func configureCollectionView() {
        datasource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCell", for: indexPath) as? ResultCell else {
                return nil
            }
            cell.user.text = item.login
            return cell
        })
        
        collectionView.collectionViewLayout = layout()
        collectionView.delegate = self
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func bind() {
        viewModel.$users
            .receive(on: RunLoop.main)
            .sink { users in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(users, toSection: .main)
                self.datasource.apply(snapshot)
            }.store(in: &subscriptions)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let keyword = searchController.searchBar.text
        print("search: \(keyword)")
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        viewModel.search(keyword: keyword)
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let loginID = viewModel.users[indexPath.item].login
        let viewModel = UserProfileViewModel(network: NetworkService(configuration: .default), loginID: loginID)
        let userProfileView = UserProfileView(viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: userProfileView)
        navigationController?.pushViewController(hostingVC, animated: true)
    }
}
