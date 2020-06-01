import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

import RxSwift
import RxCocoa
import XCPlayground

example("just") {
    let observable = Observable.just("Mal")
    observable.subscribe({ (event) in
        print(event)
    })
}

example("of") {
    let items = [1,2,3]
    let observable = Observable.from(items)
    
    observable.subscribe({ (event) in
        print(event)
    })
    
    observable.subscribe {
        print($0)
    }
}

example("create") {
    let items = [1,2,3,4,5]
    Observable.from(items).subscribe(onNext: { (event) in
        print(event)
    }, onError: { (error) in
        print(error)
    }, onCompleted: {
        print("Completed")
    }, onDisposed: {
        print("Disposed")
        }).dispose()
}

example("DisposeBag") {
    let disposeBag = DisposeBag()
    
    Observable.from([1,2,3]).subscribe { (event) in
        print(event)
    }.disposed(by: disposeBag)
}

example("Filter") {
    let disposeBag = DisposeBag()
    let items = [1, 2, 30, 55, 44]
    Observable.from(items)
        .map { $0 * 10}
        .subscribe { (event) in
        print(event)
    }.disposed(by: disposeBag)
}

example("PublishSubject") {
    let disposeBag = DisposeBag()
    let publishSubject = PublishSubject<String>()
    
    enum ErrorType: Error {
        case Test
    }
    
    publishSubject.on(.next("Heyy"))
    
    publishSubject.subscribe {
        print($0)
    }.disposed(by: disposeBag)
    
    publishSubject.on(.next("Mal"))
    publishSubject.onNext("Kot")
    
    let secondSubscription = publishSubject.subscribe {
        print("second subs \($0)")
    }
    
    secondSubscription.disposed(by: disposeBag)
    
    publishSubject.onNext("Koilek")
    
    secondSubscription.dispose()
    
    publishSubject.onNext("After disposing the second subscriber")
    
    publishSubject.onError(ErrorType.Test)
    
    let thirdSubcription = publishSubject.subscribe {
        print("Third subs \($0)")
    }
    
    thirdSubcription.disposed(by: disposeBag)
}

example("BehaviourSubject") {
    let disposeBag = DisposeBag()
    let behaviourSubject = BehaviorSubject(value: "Bob")
    
    behaviourSubject.subscribe { (event) in
        print("1st Subscription \(event)")
    }.disposed(by: disposeBag)
    
    behaviourSubject.on(.next("Abay"))
    behaviourSubject.onNext("Kanat")
    
    let secondSubscription = behaviourSubject.subscribe { (event) in
        print("2nd Subscription \(event)")
    }
    secondSubscription.disposed(by: disposeBag)
    
    behaviourSubject.onNext("Aidar")
}

example("ReplaySubject") {
    let disposeBag = DisposeBag()
    
    let replaySubject = ReplaySubject<String>.create(bufferSize: 2)
    
    replaySubject.onNext("Abay")
    
    replaySubject.subscribe {
        print("1st \($0)")
    }.disposed(by: disposeBag)
    
    replaySubject.on(.next("Kanat"))
    replaySubject.onNext("Aidar")
    
    let secondSubscription = replaySubject.subscribe { (event) in
        print("2nd \(event)")
    }
    secondSubscription.disposed(by: disposeBag)
    
    replaySubject.onNext("Chert")
    
    let thirdSubscription = replaySubject.subscribe {
        print("3rd \($0)")
    }
    thirdSubscription.disposed(by: disposeBag)
    
    replaySubject.onNext("Mal")
}

example("observeOn") {
    let items = [1,2,3]
    _ = Observable.from(items).observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    .subscribe(onNext: {
        print("\(Thread.current) \($0)")
    }, onError: nil, onCompleted: {
        print("Completed")
    }, onDisposed: nil)
}

example("observeON and subscribeON") {
    _ = DispatchQueue.global(qos: .default)
    _ = DispatchQueue.global(qos: .default)
    
    print("Init thread \(Thread.current)")
    
    _ = Observable<Int>.create ({ (observer) -> Disposable in
        observer.onNext(1)
        observer.onNext(2)
        observer.onNext(3)
        
        return Disposables.create()
    })
        .subscribeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "queue1"))
        .observeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "queue2"))
        .subscribe { (event) in
            print("Current Thread \(Thread.current) \(event)")
    }
}


//example("without shareReplay duplicate call problem") {
//    let source = ()
//}
