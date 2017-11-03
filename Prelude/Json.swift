//
//  Json.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/9/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

import Foundation

public enum Json {
  case null
  case text(String)
  case number(Double)
  case boolean(Bool)
  case object([String:Json])
  case list([Json])
}

public extension Json {
  
  init(data: Data) throws {
    
    func mapJson(from object: Any) -> Json {
      switch object {
      case _ as NSNull: return .null
      case let string as String: return .text(string)
      case let number as NSNumber:
        let type = String(utf8String: number.objCType)
        return type == "c" ? .boolean(number.boolValue) : .number(number.doubleValue)
      case let dictionary as [String:Any]: return .object(dictionary.mapValues(mapJson))
      case let array as [Any]: return .list(array.map(mapJson))
      default: fatalError("Malformed JSON")
      }
    }
    
    let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    self = mapJson(from: object)
  }
  
}

public struct JsonReaderError: Error {
  let msg: String
  
  init(_ message: String) {
    msg = message
  }
  
  init(expected: String, in json: Json) {
    msg = "Expected \(expected) but got \(json)"
  }
}

public typealias JsonReader<Read> = Reader<Json, Read>

public extension Reader where Source == Json {
  
  func reading(from data: Data) throws -> Read {
    return try reading(from: Json(data: data))
  }
  
  var optional: JsonReader<Read?> {
    return JsonReader<Read?> { json in try? self.reading(from: json) }
  }
  
  var nullable: JsonReader<Read?> {
    return JsonReader<Read?> { json in
      if case .null = json { return nil }
      return try self.reading(from: json)
    }
  }
  
}

public extension Json {
  
  static var string: JsonReader<String> {
    return JsonReader { json in
      guard case let .text(str) = json else { throw JsonReaderError(expected: "string", in: json) }
      return str
    }
  }
  
  static var url: JsonReader<URL> {
    return string.map { str in
      guard let url = URL(string: str) else { throw JsonReaderError("\"\(str)\" is not a valid url") }
      return url
    }
  }
  
  static var double: JsonReader<Double> {
    return JsonReader { json in
      guard case let .number(num) = json else { throw JsonReaderError(expected: "number", in: json) }
      return num
    }
  }
  
  static var int: JsonReader<Int> {
    return double.map { num in
      guard let i = Int(exactly: num) else { throw JsonReaderError("\(num) is not an integer") }
      return i
    }
  }
  
  static var bool: JsonReader<Bool> {
    return JsonReader { json in
      guard case let .boolean(bool) = json else { throw JsonReaderError(expected: "bool", in: json) }
      return bool
    }
  }
  
  static var dictionary: JsonReader<[String:Json]> {
    return JsonReader { json in
      guard case let .object(dict) = json else { throw JsonReaderError(expected: "dictionary", in: json) }
      return dict
    }
  }
  
  static func dictionary(key: String) -> JsonReader<Json> {
    return dictionary.map { dict in
      guard let x = dict[key] else { throw JsonReaderError("key: \"\(key)\" not found in \(dict)") }
      return x
    }
  }
  
  static var array: JsonReader<[Json]> {
    return JsonReader { json in
      guard case let .list(arr) = json else { throw JsonReaderError(expected: "array", in: json) }
      return arr
    }
  }
  
  static func array(at index: Int) -> JsonReader<Json> {
    return array.map { arr in
      guard arr.startIndex <= index && index < arr.endIndex else { throw JsonReaderError("index: \(index) out of bounds in \(arr)") }
      return arr[index]
    }
  }
  
}

extension Json: Equatable {
  public static func == (lhs: Json, rhs: Json) -> Bool {
    switch (lhs, rhs) {
    case (.null, .null): return true
    case let (.text(s1), .text(s2)): return s1 == s2
    case let (.number(n1), .number(n2)): return n1 == n2
    case let (.boolean(b1), .boolean(b2)): return b1 == b2
    case let (.object(d1), .object(d2)): return d1 == d2
    case let (.list(a1), .list(a2)): return a1 == a2
    default: return false
    }
  }
}

extension Json: CustomStringConvertible {
  public var description: String {
    switch self {
    case .null: return "null"
    case let .text(s): return "\"\(s)\""
    case let .number(n): return "\(n)"
    case let .boolean(b): return "\(b)"
    case let .object(dict): return "\(dict)"
    case let .list(arr): return "\(arr)"
    }
  }
}

public protocol JsonDecodable {
  init(json: Json) throws
  static var jsonReader: JsonReader<Self> { get }
}

public extension JsonDecodable {
  init(json: Json) throws {
    self = try Self.jsonReader.reading(from: json)
  }
  
  static var jsonReader: JsonReader<Self> {
    return JsonReader { json in try Self(json: json) }
  }
  
  init(data: Data) throws {
    try self.init(json: Json(data: data))
  }
}
