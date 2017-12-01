//
//  Transaction.swift
//  Prelude
//
//  Created by Kristofer Hanes on 2017-11-28.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

public struct Transaction<Context: AnyObject, Wrapped> {
  private let transact: (Context) -> Async<Wrapped>
  
  public init(_ transaction: @escaping (Context) -> Async<Wrapped>) {
    transact = transaction
  }
  
  public init(_ transaction: @escaping (Context) -> Wrapped) {
    transact = Async.converting(transaction)
  }
  
  public func run(from context: Context, _ callback: @escaping (Status<Wrapped>) -> ()) {
    transact(context).run(callback)
  }
  
  public func async(with context: Context) -> Async<Wrapped> {
    return transact(context)
  }
}

public extension Transaction { // Functor
  
  func map<Mapped>(_ transform: @escaping (Wrapped) throws -> Mapped) -> Transaction<Context, Mapped> {
    return Transaction<Context, Mapped> { context in
      Async { yield in self.transact(context).map(transform).run { yield($0) } }
    }
  }
  
}

public extension Transaction { // Applicative
  
  static func pure(_ value: Wrapped) -> Transaction {
    return Transaction { _ in .pure(value) }
  }
  
  static func <*> <Mapped>(_ transform: Transaction<Context, (Wrapped) -> Mapped>, transaction: Transaction) -> Transaction<Context, Mapped> {
    return Transaction<Context, Mapped> { context in
      Async<Mapped> { yield in
        let transform = transform.transact(context)
        let value = transaction.transact(context)
        let transformed = transform.flatMap { fn in value.map { x in fn(x) } } // sequential application
        transformed.run { yield($0) }
      }
    }
  }
  
}

public extension Transaction { // Monad
  
  func flatMap<Mapped>(_ transform: @escaping (Wrapped) throws -> Transaction<Context, Mapped>) -> Transaction<Context, Mapped> {
    return Transaction<Context, Mapped> { context in
      Async { yield in
        self.transact(context).run { status in
          switch status {
          case let .ok(value):
            do {
              let newTransaction = try transform(value)
              let newValue = newTransaction.transact(context)
              newValue.run { yield($0) }
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
  
}
