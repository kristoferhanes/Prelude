//
//  Status.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/8/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

enum Status<Wrapped> {
  case ok(Wrapped)
  case error(Error)
}

extension Status {
  
  static func pure(_ value: Wrapped) -> Status {
    return .ok(value)
  }
  
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
  
  static func <*> <Mapped>(transform: Status<(Wrapped) throws -> Mapped>, status: Status) -> Status<Mapped> {
    switch transform {
    case let .ok(f):
      return status.map(f)
    case let .error(error):
      return .error(error)
    }
  }
  
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
