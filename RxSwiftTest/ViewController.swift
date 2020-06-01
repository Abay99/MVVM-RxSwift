//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by Abai Kalikov on 5/25/20.
//  Copyright © 2020 Abai Kalikov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    let disposeBag = DisposeBag()
    let textFieldText = BehaviorRelay<String?>(value: "")
    let buttonSubject = PublishSubject<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showTextFieldResult()
        configureButton()
    }

    private func showTextFieldResult() {
        textField.rx.text.bind(to: textFieldText).disposed(by: disposeBag)
        textFieldText.asObservable().subscribe(onNext: {
            guard let event = $0 else { return }
            print(event)
        }).disposed(by: disposeBag)
    }
    
    private func configureButton() {
        button.rx.tap.map { "MAl" }.bind(to: buttonSubject).disposed(by: disposeBag)
        buttonSubject.asObservable().subscribe(onNext: {
            print("Button \($0)")
            }).disposed(by: disposeBag)
    }
}
