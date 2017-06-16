//
//  Json.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/9/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

import Foundation

enum Json {
  case null
  case text(String)
  case number(Double)
  case boolean(Bool)
  case object([String: Json])
  case list([Json])
}

struct JsonInitError: Error { }

extension Json {
  
  init(data: Data) throws {
    
    func mapJson(from object: Any) -> Json? {
      switch object {
      case _ as NSNull: return .null
      case let string as String: return .text(string)
      case let number as NSNumber:
        let type = String(utf8String: number.objCType)
        return type == "c" ? .boolean(number.boolValue) : .number(number.doubleValue)
      case let dictionary as [String:Any]: return dictionary.traverse(mapJson).map(Json.object)
      case let array as [Any]: return array.traverse(mapJson).map(Json.list)
      default: return nil
      }
    }
    
    let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    guard let mapped = mapJson(from: object)
      else { throw JsonInitError() }
    self = mapped
  }
  
  var isNull: Bool {
    guard case .null = self else { return false }
    return true
  }
  
}

typealias JsonReader<Read> = Reader<Json, Read>

struct JsonReaderError: Error {
  let message: String
  
  init(_ message: String) {
    self.message = message
  }
}

extension Reader where Source == Json {
  
  var optional: JsonReader<Read?> {
    return JsonReader<Read?> { json in try? self.reading(from: json) }
  }
  
  var nullable: JsonReader<Read?> {
    return JsonReader<Read?> { json in
      if json.isNull { return nil }
      return try self.reading(from: json)
    }
  }
  
}

extension Json {
  
  static var string: JsonReader<String> {
    return JsonReader { json in
      guard case let .text(str) = json else { throw JsonReaderError("expected string") }
      return str
    }
  }
  
  static var double: JsonReader<Double> {
    return JsonReader { json in
      guard case let .number(num) = json else { throw JsonReaderError("expected double") }
      return num
    }
  }
  
  static var int: JsonReader<Int> {
    return JsonReader { json in
      guard case let .number(num) = json else { throw JsonReaderError("expected integer") }
      guard let i = Int(exactly: num) else { throw JsonReaderError("\(num) is not an integer") }
      return i
    }
  }
  
  static var bool: JsonReader<Bool> {
    return JsonReader { json in
      guard case let .boolean(bool) = json else { throw JsonReaderError("expected bool") }
      return bool
    }
  }
  
  static func dictionary(key: String) -> JsonReader<Json> {
    return JsonReader { json in
      guard case let .object(dict) = json else { throw JsonReaderError("expected object") }
      guard let x = dict[key] else { throw JsonReaderError("key: \(key) not found") }
      return x
    }
  }
  
  static func array(at index: Int) -> JsonReader<Json> {
    return JsonReader { json in
      guard case let .list(arr) = json else { throw JsonReaderError("expected array") }
      guard arr.startIndex <= index && index < arr.endIndex else { throw JsonReaderError("index: \(index) out of bounds") }
      return arr[index]
    }
  }
  
}

extension Json: Equatable {
  static func == (lhs: Json, rhs: Json) -> Bool {
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

private extension Dictionary {
  func traverse<Mapped>(_ transform: (Value) throws -> Mapped?) rethrows -> [Key:Mapped]? {
    var result = [Key:Mapped](minimumCapacity: count)
    for (key, value) in self {
      guard let newValue = try transform(value) else { return nil }
      result[key] = newValue
    }
    return result
  }
}

private extension Array {
  func traverse<Mapped>(_ transform: (Element) throws -> Mapped?) rethrows -> [Mapped]? {
    var result: [Mapped] = []
    result.reserveCapacity(count)
    for element in self {
      guard let newElement = try transform(element) else { return nil }
      result.append(newElement)
    }
    return result
  }
}
