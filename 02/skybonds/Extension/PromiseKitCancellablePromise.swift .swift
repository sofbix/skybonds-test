//
//  PromiseKitCancellablePromise.swift .swift
//  skybonds
//
//  Created by Sergey Balalaev on 08.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//


import Foundation
import PromiseKit

protocol CancellableProtocol : class {
    func cancel()
}

class PromiseCancelledError : CancellableError {
    var isCancelled: Bool {
        return true
    }
}

class CancellablePromise<T> : CancellableProtocol, Thenable, CatchMixin {

    var promise: Promise<T>?
    var resolver: Resolver<T>? = nil
    var cancellable: CancellableProtocol?

    init(resolver: ((Resolver<T>) throws ->()), cancellable: CancellableProtocol? = nil) {

        self.cancellable = cancellable
        self.promise = Promise<T>.init(resolver: {[weak self] (_resolver) in
            self?.resolver = _resolver
            try resolver(_resolver)
        })
    }


    init(promise:Promise<T>, resolver: Resolver<T>, cancellable: CancellableProtocol? = nil) {
        self.promise = promise
        self.resolver = resolver
        self.cancellable = cancellable
    }

    func cancel() {
        guard promise?.isPending ?? false else {
            return
        }
        self.resolver?.reject(PromiseCancelledError())
        cancellable?.cancel()
    }

    var value: T? {
        return promise?.value
    }
    
    func pipe(to: @escaping (PromiseKit.Result<T>) -> Void) {
        promise?.pipe(to: to)
    }
    
    var result: PromiseKit.Result<T>? {
        return promise?.result
    }
    

    func _map<U>( _ transform: @escaping (T) throws -> U) -> CancellablePromise<U> {
        
        return CancellablePromise<U>.init(resolver: { (_resolver) in
            self.pipe(to: { (result) in
                _resolver.resolve(result.map(transform))
            })
        }, cancellable: self.cancellable)
    }
}

extension PromiseKit.Result {
    
    func map<U>(_ transform: @escaping (T) throws -> U) -> PromiseKit.Result<U> {
        switch self {
        case .fulfilled(let value):
        do {
            let mappedValue = try transform(value)
            return PromiseKit.Result<U>.fulfilled(mappedValue)
        } catch (let error) {
            return PromiseKit.Result<U>.rejected(error)
        }
        case .rejected(let error):
            return PromiseKit.Result<U>.rejected(error)
        }
    }
    
}
