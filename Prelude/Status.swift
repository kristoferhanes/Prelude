//
//  Status.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/8/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

public enum Status<Wrapped> {
  case ok(Wrapped)
  case error(Error)
}

public extension Status {
  
  var ok: Wrapped? {
    guard case let .ok(ok) = self else { return nil }
    return ok
  }
  
  var error: Error? {
    guard case let .error(error) = self else { return nil }
    return error
  }
  
}

public extension Status { // Functor
  
  func map<Mapped>(_ transform: (Wrapped) throws -> Mapped) -> Status<Mapped> {
    switch self {
    case let .ok(value):
      do {
        return .ok(try transform(value))
      }
      catch {
        return .error(error)
      }
    case let .error(error):
      return .error(error)
    }
  }
  
  static func <^> <Mapped>(transform: (Wrapped) throws -> Mapped, status: Status) -> Status<Mapped> {
    return status.map(transform)
  }
  
}

public extension Status { // Applicative
  
  static func pure(_ value: Wrapped) -> Status {
    return .ok(value)
  }
  
  static func <*> <Mapped>(transform: Status<(Wrapped) -> Mapped>, status: Status) -> Status<Mapped> {
    switch transform {
    case let .ok(f):
      return status.map(f)
    case let .error(error):
      return .error(error)
    }
  }
  
}

public extension Status { // Monad

  func flatMap<Mapped>(_ transform: (Wrapped) throws -> Status<Mapped>) -> Status<Mapped> {
    switch self {
    case let .ok(value):
      do {
        return try transform(value)
      }
      catch {
        return .error(error)
      }
    case let .error(error):
      return .error(error)
    }
  }
  
}
