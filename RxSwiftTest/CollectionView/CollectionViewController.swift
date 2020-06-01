//
//  CollectionViewController.swift
//  RxSwiftTest
//
//  Created by Abai Kalikov on 5/27/20.
//  Copyright © 2020 Abai Kalikov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

extension String {
    public typealias Identity = String
    public var identity: Identity { return self }
}

struct AnimatedSectionModel {
    let title: String
    var data: [String]
}

extension AnimatedSectionModel: AnimatableSectionModelType {
    typealias Item = String
    typealias Identity = String
    
    var identity: Identity { return title }
    var items: [Item] { return data }
    
    init(original: AnimatedSectionModel, items: [String]) {
        self = original
        self.data = items
    }
}

class CollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var longPressGR: UILongPressGestureRecognizer!
    
    let disposeBag = DisposeBag()
    
//    let data = BehaviorRelay(value: [
//        AnimatedSectionModel(title: "Section: 0", data: ["0-0"])
//    ])
    let data = Variable([
        AnimatedSectionModel(title: "Section: 0", data: ["0-0"])
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatedSectionModel>(
            configureCell: { _, collectionView, indexPath, title in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
            cell.titleLabel.text = title
            
            return cell
        })
        
        dataSource.configureSupplementaryView = {dataSource, collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! Header
            header.titleLabel.text = "Section: \(self.data.value.count)"
            
            return header
        }
    
        data.asDriver().drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        addBarButtonItem.rx.tap.asDriver().drive(onNext: {
            let section = self.data.value.count
            let items: [String] = {
                var items = [String]()
                let random = Int(arc4random_uniform(5)) + 1
                (0...random).forEach {
                    items.append("\(section) - \($0)")
                }
                return items
            }()
            self.data.value += [AnimatedSectionModel(title: "Section \(section)", data: items)]
        }).disposed(by: disposeBag)
        
        longPressGR.rx.event.subscribe(onNext: {
            switch $0.state {
            case .began:
                guard let selectedIndexPath = self.collectionView.indexPathForItem(at: $0.location(in: self.collectionView)) else { break }
                self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            case .changed:
                self.collectionView.updateInteractiveMovementTargetPosition($0.location(in: $0.view!))
            case .ended:
                self.collectionView.endInteractiveMovement()
            default:
                self.collectionView.cancelInteractiveMovement()
            }
        }).disposed(by: disposeBag)
    }
}
