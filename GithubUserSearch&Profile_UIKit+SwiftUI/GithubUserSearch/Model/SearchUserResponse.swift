//
//  SearchUserResponse.swift
//  GithubUserSearch
//
//  Created by Yuhyeon Kim on 2023/01/04.
//

import Foundation

struct SearchUserResponse: Decodable {
    var items: [SearchResult]
}
