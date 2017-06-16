//
//  Callback.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/8/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

import Foundation

struct Callback<Wrapped> {
  private let operation: (@escaping (Status<Wrapped>) -> ()) -> ()
  
  init(_ operation: @escaping (@escaping (Status<Wrapped>) -> ()) -> ()) {
    self.operation = operation
  }
  
  func run(_ callback: @escaping (Status<Wrapped>) -> ()) {
    operation(callback)
  }
}

extension Callback {
  
  static func convert<Input>(_ fn: @escaping (Input) throws -> Wrapped) -> (Input) -> Callback {
    return { input in
      return Callback { yield in
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
  
  func transferred(to queue: DispatchQueue) -> Callback {
    return Callback { yield in
      self.run { status in
        queue.async {
          yield(status)
        }
      }
    }
  }
  
  var transferredToMainQueue: Callback {
    return transferred(to: DispatchQueue.main)
  }
  
  static func pure(_ value: Wrapped) -> Callback {
    return Callback { yield in yield(.ok(value)) }
  }
  
  func map<Mapped>(_ transform: @escaping (Wrapped) throws -> Mapped) -> Callback<Mapped> {
    return Callback<Mapped> { yield in
      self.run { status in
        yield(transform <^> status)
      }
    }
  }
  
  static func <^> <Mapped>(transform: @escaping (Wrapped) throws -> Mapped, callback: Callback) -> Callback<Mapped> {
    return callback.map(transform)
  }
  
  static func <*> <Mapped>(transform: Callback<(Wrapped) throws -> Mapped>, callback: Callback) -> Callback<Mapped> {
    return Callback<Mapped> { yield in
      transform.run { fn in
        callback.run { value in
          yield(fn <*> value)
        }
      }
    }
  }
  
  func flatMap<Mapped>(_ transform: @escaping (Wrapped) throws -> Callback<Mapped>) -> Callback<Mapped> {
    return Callback<Mapped> { yield in
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
  
}
