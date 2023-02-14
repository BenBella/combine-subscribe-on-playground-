import Foundation
import Combine

var cancelables = Set<AnyCancellable>()

Just("Some text")
    .map { _ in
        print("Downstram map: \(Thread.isMainThread)")
    }
    .subscribe(on: DispatchQueue.global())
    .handleEvents(receiveRequest: { _ in
        print("Upstream: \(Thread.isMainThread)")
    })
    .sink { _ in
        print("Downstream sink: \(Thread.isMainThread)")
    }
    .store(in: &cancelables)

/*
Output
Map: true
Sink: false
*/

Just("Some text")
    .handleEvents(receiveRequest: { _ in
        print("Upstream: \(Thread.isMainThread)")
    })
    .subscribe(on: DispatchQueue.global())
    .map { _ in
        print("Downstram map: \(Thread.isMainThread)")
    }
    .sink { _ in
        print("Downstram sink: \(Thread.isMainThread)")
    }
    .store(in: &cancelables)

/*
Output
Map: false
Sink: false
*/

struct TestJust<Output>: Publisher {
    typealias Failure = Never
    
    private let value: Output
    
    init(_ output: Output) {
        self.value = output
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: Subscriptions.empty)
        _ = subscriber.receive(value)
        subscriber.receive(completion: .finished)
    }
}

TestJust("Some text")
    .handleEvents(receiveRequest: { _ in
        print("Upstream: \(Thread.isMainThread)")
    })
    .subscribe(on: DispatchQueue.global())
    .map { _ in
        print("Downstream map: \(Thread.isMainThread)")
    }
   
    .sink { _ in
        print("Downstram map: \(Thread.isMainThread)")
    }
    .store(in: &cancelables)

/*
Output
Map: false
Sink: false
*/
