//
//  ViewModel.swift
//  RxSwiftTest
//
//  Created by Abai Kalikov on 5/27/20.
//  Copyright © 2020 Abai Kalikov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    let searchText = PublishSubject<String?>()
    let disposeBag = DisposeBag()
    
    let APIProvider: APIProvider
    var data: Driver<[Repository]>
    
    init(APIProvider: APIProvider) {
        self.APIProvider = APIProvider
        data = searchText.asObservable()
                    .throttle(0.3, scheduler: MainScheduler.instance)
                    .distinctUntilChanged()
                    .flatMapLatest {
                        APIProvider.getRepositories($0!)
                    }.asDriver(onErrorJustReturn: [])
    }
}
