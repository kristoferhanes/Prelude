//
//  Writer.swift
//  Prelude
//
//  Created by Kristofer Hanes on 2017-10-28.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

public struct Writer<Written, Wrapped> {
  let value: Wrapped
  let written: Written
}

public extension Writer { // Functor
  func map<Mapped>(_ transform: (Wrapped) throws -> Mapped) rethrows -> Writer<Written, Mapped> {
    return Writer<Written, Mapped>(value: try transform(value), written: written)
  }
  
  static func <^> <Mapped>(transform: (Wrapped) throws -> Mapped, writer: Writer) rethrows -> Writer<Written, Mapped> {
    return try writer.map(transform)
  }
}

public extension Writer where Written: Monoid { // Applicative
  static func pure(_ value: Wrapped) -> Writer {
    return Writer(value: value, written: Written.identity)
  }
  
  static func <*> <Mapped>(transform: Writer<Written, (Wrapped) -> Mapped>, writer: Writer) -> Writer<Written, Mapped> {
    return Writer<Written, Mapped>(
      value: transform.value(writer.value),
      written: Written.combine(transform.written, writer.written)
    )
  }
}

public extension Writer where Written: Monoid { // Monad
  func flatMap<Mapped>(_ transform: (Wrapped) throws -> Writer<Written, Mapped>) rethrows -> Writer<Written, Mapped> {
    let newWriter = try transform(value)
    return Writer<Written, Mapped>(value: newWriter.value, written: Written.combine(written, newWriter.written))
  }
}
