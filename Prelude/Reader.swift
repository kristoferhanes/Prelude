//
//  Reader.swift
//  Parser
//
//  Created by Kristofer Hanes on 6/14/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

public struct Reader<Source, Read> {
  private let read: (Source) throws -> Read
  
  init(_ reader: @escaping (Source) throws -> Read) {
    read = reader
  }
  
  func reading(from source: Source) throws -> Read {
    return try read(source)
  }
}

public extension Reader { // Functor
  
  func map<Mapped>(_ transform: @escaping (Read) throws -> Mapped) -> Reader<Source, Mapped> {
    return Reader<Source, Mapped> { source in try transform(self.reading(from: source)) }
  }
  
  static func <^> <Mapped>(transform: @escaping (Read) throws -> Mapped, reader: Reader) -> Reader<Source, Mapped> {
    return reader.map(transform)
  }
  
}

public extension Reader { // Applicative

  static func pure(_ value: Read) -> Reader {
    return Reader { _ in value }
  }
  
  static func <*> <Mapped>(transform: Reader<Source, (Read) throws -> Mapped>, reader: Reader) -> Reader<Source, Mapped> {
    return Reader<Source, Mapped> { source in
      let fn = try transform.reading(from: source)
      return try fn(reader.reading(from: source))
    }
  }
  
}

public extension Reader { // Monad

  func flatMap<Mapped>(_ transform: @escaping (Read) throws -> Reader<Source, Mapped>) -> Reader<Source, Mapped> {
    return Reader<Source, Mapped> { source in try transform(self.reading(from: source)).reading(from: source) }
  }
  
}

public extension Reader { // Category

  static var identity: Reader<Read, Read> {
    return Reader<Read, Read> { $0 }
  }
  
  static func >>> <Composed>(reader1: Reader, reader2: Reader<Read, Composed>) -> Reader<Source, Composed> {
    return Reader<Source, Composed>(reader1.reading >>> reader2.reading)
  }
  
  static func <<< <Composed>(reader1: Reader<Read, Composed>, reader2: Reader) -> Reader<Source, Composed> {
    return reader2 >>> reader1
  }
  
}

public extension Reader { // Contravariant
  func contramap<Mapped>(_ transform: @escaping (Mapped) throws -> Source) -> Reader<Mapped, Read> {
    return Reader<Mapped, Read> { source in try self.reading(from: transform(source)) }
  }
}

public extension Reader where Read: Monoid { // Monoid
  static var identity: Reader {
    return Reader { _ in Read.identity }
  }
  
  static func combine(_ lhs: Reader, _ rhs: Reader) -> Reader {
    return Reader { source in
      return try Read.combine(lhs.reading(from: source), rhs.reading(from: source))
    }
  }
}
