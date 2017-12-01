//
//  Async.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/8/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

import class Foundation.DispatchQueue
import class Foundation.DispatchGroup
import class Foundation.DispatchSemaphore
import struct Foundation.DispatchQoS

public struct Async<Wrapped> {
  private let operation: (@escaping (Status<Wrapped>) -> ()) -> ()
  
  public init(_ operation: @escaping (@escaping (Status<Wrapped>) -> ()) -> ()) {
    self.operation = operation
  }
  
  public func run(_ callback: @escaping (Status<Wrapped>) -> ()) {
    operation(callback)
  }
  
  public func await() throws -> Wrapped {
    let semaphore = DispatchSemaphore(value: 0)
    var result: Status<Wrapped>?
    run { status in
      result = status
      semaphore.signal()
    }
    semaphore.wait()
    switch result! {
    case let .ok(value):
      return value
    case let .error(error):
      throw error
    }
  }
}

public extension Async {
  
  init(qos: DispatchQoS.QoSClass = .default, operation: @escaping () throws -> Wrapped) {
    self.operation = { yield in
      DispatchQueue.global(qos: qos).async {
        do {
          try yield(.ok(operation()))
        }
        catch {
          yield(.error(error))
        }
      }
    }
  }
  
  init(queue: DispatchQueue, operation: @escaping () throws -> Wrapped) {
    self.operation = { yield in
      queue.async {
        do {
          try yield(.ok(operation()))
        }
        catch {
          yield(.error(error))
        }
      }
    }
  }
  
  static func converting<Input>(_ fn: @escaping (Input) throws -> Wrapped) -> (Input) -> Async {
    return { input in
      return Async { yield in
        do {
          let result = try fn(input)
          yield(.ok(result))
        }
        catch {
          yield(.error(error))
        }
      }
    }
  }
  
  func transferred(to queue: DispatchQueue) -> Async {
    return Async { yield in
      self.run { status in
        queue.async {
          yield(status)
        }
      }
    }
  }
  
  var transferredToMainQueue: Async {
    return transferred(to: DispatchQueue.main)
  }
  
}

public extension Async { // Functor
  
  func map<Mapped>(_ transform: @escaping (Wrapped) throws -> Mapped) -> Async<Mapped> {
    return Async<Mapped> { yield in
      self.run { status in
        yield(transform <^> status)
      }
    }
  }
  
  static func <^> <Mapped>(transform: @escaping (Wrapped) throws -> Mapped, async: Async) -> Async<Mapped> {
    return async.map(transform)
  }
  
}

public extension Async { // Applicative

  static func pure(_ value: Wrapped) -> Async {
    return Async { yield in yield(.ok(value)) }
  }
  
  static func <*> <Mapped>(transform: Async<(Wrapped) -> Mapped>, async: Async) -> Async<Mapped> {
    return Async<Mapped> { yield in
      let group = DispatchGroup()
      
      var fn: Status<((Wrapped) -> Mapped)>!
      var x: Status<Wrapped>!
      
      DispatchQueue.global().async(group: group) {
        transform.run { fn = $0 }
      }
      
      DispatchQueue.global().async(group: group) {
        async.run { x = $0 }
      }
      
      group.notify(queue: DispatchQueue.global()) {
        yield(fn <*> x)
      }
    }
  }
  
  static func *> <Ignored>(ignored: Async<Ignored>, async: Async) -> Async {
    return snd <^> ignored <*> async
  }

  static func <* <Ignored>(async: Async, ignored: Async<Ignored>) -> Async {
    return fst <^> async <*> ignored
  }

}

public extension Async { // Monad

  func flatMap<Mapped>(_ transform: @escaping (Wrapped) throws -> Async<Mapped>) -> Async<Mapped> {
    return Async<Mapped> { yield in
      self.run { status in
        switch status {
        case let .ok(value):
          do {
            let newAsync = try transform(value)
            newAsync.run(yield)
          }
          catch {
            yield(.error(error))
          }
        case let .error(error):
          yield(.error(error))
        }
      }
    }
  }
  
}
