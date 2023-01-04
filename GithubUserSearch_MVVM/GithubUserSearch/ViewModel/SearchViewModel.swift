//
//  SearchViewModel.swift
//  GithubUserSearch
//
//  Created by Yuhyeon Kim on 2023/01/04.
//

import Foundation
import Combine

final class SearchViewModel {
    let network: NetworkService
    
    init(network: NetworkService) {
        self.network = network
    }
    
    var subscriptions = Set<AnyCancellable>()
    @Published private(set) var users: [SearchResult] = []
    
    func search(keyword: String) {
        let resource = Resource<SearchUserResponse>(
            base: "https://api.github.com/",
            path: "search/users",
            params: ["q" : keyword],
            header: ["Content-Type" : "appllication/json"]
        )
        
        network.load(resource)
            .map { $0.items }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.users, on: self)
            .store(in: &subscriptions)
    }
}
