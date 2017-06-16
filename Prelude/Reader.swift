//
//  Reader.swift
//  Parser
//
//  Created by Kristofer Hanes on 6/14/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

struct Reader<Source, Read> {
  private let read: (Source) throws -> Read
  
  init(_ reader: @escaping (Source) throws -> Read) {
    read = reader
  }
  
  func reading(from source: Source) throws -> Read {
    return try read(source)
  }
}

extension Reader {
  
  static func pure(_ value: Read) -> Reader {
    return Reader { _ in value }
  }
  
  func map<Mapped>(_ transform: @escaping (Read) throws -> Mapped) -> Reader<Source, Mapped> {
    return Reader<Source, Mapped> { source in try transform(self.reading(from: source)) }
  }
  
  static func <^> <Mapped>(transform: @escaping (Read) throws -> Mapped, reader: Reader) -> Reader<Source, Mapped> {
    return reader.map(transform)
  }
  
  static func <*> <Mapped>(transform: Reader<Source, (Read) throws -> Mapped>, reader: Reader) -> Reader<Source, Mapped> {
    return Reader<Source, Mapped> { source in
      let fn = try transform.reading(from: source)
      return try fn(reader.reading(from: source))
    }
  }
  
  func flatMap<Mapped>(_ transform: @escaping (Read) throws -> Reader<Source, Mapped>) -> Reader<Source, Mapped> {
    return Reader<Source, Mapped> { source in try transform(self.reading(from: source)).reading(from: source) }
  }
  
}
