//
//  SearchViewModel.swift
//  GithubUserProfile
//
//  Created by Yuhyeon Kim on 2023/01/04.
//

import Foundation
import Combine

final class SearchViewModel {
    
    let network: NetworkService
    
    init(network: NetworkService, selectedUser: UserProfile?) {
        self.network = network
        self.selectedUser = CurrentValueSubject(selectedUser)
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    // Data -> Output
    let selectedUser: CurrentValueSubject<UserProfile?, Never>
    var name: String {
        return selectedUser.value?.name ?? "N/A"
    }
    var login: String {
        return selectedUser.value?.login ?? "N/A"
    }
    var followers: String {
        guard let value = selectedUser.value?.followers else { return "" }
        return "follwers: \(value)"
    }
    var following: String {
        guard let value = selectedUser.value?.following else { return "" }
        return "follwing: \(value)"
    }
    var imageURL: URL? {
        return selectedUser.value?.avatarUrl
    }
    
    // User Action -> Input
    func search(keyword: String) {
        let resource = Resource<UserProfile>(base: "http://api.github.com/", path: "users/\(keyword)",params: [:], header: ["Content-Type": "apllication/json"])
        
        network.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.selectedUser.send(nil)
                case .finished: break
                }
            } receiveValue: { user in
                self.selectedUser.send(user)
            }.store(in: &subscriptions)
    }
}
