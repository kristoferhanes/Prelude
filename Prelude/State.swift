//
//  State.swift
//  Prelude
//
//  Created by Kristofer Hanes on 2017-11-29.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

struct State<Context, Wrapped> {
  private let operation: (inout Context) throws -> Wrapped
  
  init(_ operation: @escaping (inout Context) throws -> Wrapped) {
    self.operation = operation
  }
  
  func run(_ state: inout Context) throws -> Wrapped {
    return try operation(&state)
  }
}

extension State { // Functor
  
  func map<Mapped>(_ transform: @escaping (Wrapped) throws -> Mapped) -> State<Context, Mapped> {
    return State<Context, Mapped> { context in
      let result = try self.operation(&context)
      return try transform(result)
    }
  }
  
  static func <^> <Mapped>(transform: @escaping (Wrapped) throws -> Mapped, state: State) -> State<Context, Mapped> {
    return state.map(transform)
  }
  
}

extension State { // Applicative
  
  static func pure(_ value: Wrapped) -> State {
    return State { _ in value }
  }
  
  static func <*> <Mapped>(transform: State<Context, (Wrapped) -> Mapped>, state: State) -> State<Context, Mapped> {
    return State<Context, Mapped> { context in
      let transform = try transform.run(&context)
      return try state.map(transform).run(&context)
    }
  }
  
}

extension State { // Monad
  
  func flatMap<Mapped>(_ transform: @escaping (Wrapped) throws -> State<Context, Mapped>) -> State<Context, Mapped> {
    return State<Context, Mapped> { context in
      let value = try self.run(&context)
      let newState = try transform(value)
      return try newState.run(&context)
    }
  }
  
}
