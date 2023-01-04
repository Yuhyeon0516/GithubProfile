//
//  SearchUserResponse.swift
//  GithubUserSearch
//
//  Created by Yuhyeon Kim on 2023/01/22.
//

import Foundation

struct SearchUserResponse: Decodable {
    var items: [SearchResult]
}
