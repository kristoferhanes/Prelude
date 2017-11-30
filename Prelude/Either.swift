//
//  Either.swift
//  Prelude
//
//  Created by Kristofer Hanes on 2017-11-29.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

enum Either<Left, Right> {
  case left(Left)
  case right(Right)
}

extension Either { // Functor
  
  func map<Mapped>(_ transform: (Right) throws -> Mapped) rethrows -> Either<Left, Mapped> {
    switch self {
    case let .left(left):
      return .left(left)
    case let .right(right):
      return .right(try transform(right))
    }
  }
  
  static func <^> <Mapped>(transform: (Right) throws -> Mapped, either: Either) rethrows -> Either<Left, Mapped> {
    return try either.map(transform)
  }
  
}

extension Either { // Applicative
  
  static func pure(_ value: Right) -> Either {
    return .right(value)
  }
  
  static func <*> <Mapped>(transform: Either<Left, (Right) -> Mapped>, either: Either) -> Either<Left, Mapped> {
    switch transform {
    case let .left(left):
      return .left(left)
    case let .right(transform):
      return either.map(transform)
    }
  }
  
}

extension Either { // Monad
  
  func flatMap<Mapped>(_ transform: (Right) throws -> Either<Left, Mapped>) rethrows -> Either<Left, Mapped> {
    switch self {
    case let .left(left):
      return .left(left)
    case let .right(right):
      return try transform(right)
    }
  }
  
}
