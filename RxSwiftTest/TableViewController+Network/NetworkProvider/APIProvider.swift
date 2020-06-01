//
//  APIProvider.swift
//  RxSwiftTest
//
//  Created by Abai Kalikov on 5/27/20.
//  Copyright © 2020 Abai Kalikov. All rights reserved.
//

import Foundation
import RxSwift

class APIProvider {
    func getRepositories(_ githubID: String) -> Observable<[Repository]> {
        guard !githubID.isEmpty,
            let url = URL(string: "https://api.github.com/users/\(githubID)/repos")
            else { return Observable.just([]) }
        return URLSession.shared
        .rx.json(url: url)
        .retry(3)
        .map {
            var repositories = [Repository]()
            
            if let items = $0 as? [[String: AnyObject]] {
                items.forEach {
                    guard let name = $0["name"] as? String,
                        let url = $0["html_url"] as? String else { return }
                    repositories.append(Repository(name: name, url: url))
                }
            }
     
            return repositories
        }
    }
}
