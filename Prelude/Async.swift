//
//  Async.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/8/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

import Foundation

public struct Async<Wrapped> {
  private let operation: (@escaping (Status<Wrapped>) -> ()) -> ()
  
  init(_ operation: @escaping (@escaping (Status<Wrapped>) -> ()) -> ()) {
    self.operation = operation
  }
  
  func run(_ callback: @escaping (Status<Wrapped>) -> ()) {
    operation(callback)
  }
}

public extension Async {
  
  static func convert<Input>(_ fn: @escaping (Input) throws -> Wrapped) -> (Input) -> Async {
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
      let queue = DispatchQueue(label: "\(Async.self).<*>", attributes: .concurrent)
      
      var fn: Status<((Wrapped) -> Mapped)>!
      var x: Status<Wrapped>!
      
      queue.async(group: group) {
        transform.run { status in
          fn = status
        }
      }
      
      queue.async(group: group) {
        async.run { status in
          x = status
        }
      }
      
      group.notify(queue: queue) {
        yield(fn <*> x)
      }
    }
  }
  
}

public extension Async { // Monad

  func flatMap<Mapped>(_ transform: @escaping (Wrapped) throws -> Async<Mapped>) -> Async<Mapped> {
    return Async<Mapped> { yield in
      self.run { status in
        switch status {
        case let .ok(value):
          do {
            let newCallback = try transform(value)
            newCallback.run(yield)
          }
          catch {
            yield(.error(error))
          }
        case let .error(e):
          yield(.error(e))
        }
      }
    }
  }
  
  func then<Other>(_ other: Async<Other>) -> Async<Other> {
    return flatMap { _ in other }
  }
  
}
