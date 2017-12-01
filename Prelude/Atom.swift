//
//  Atom.swift
//  Prelude
//
//  Created by Kristofer Hanes on 2017-11-23.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

import class Foundation.DispatchQueue
import struct Foundation.UUID

public final class Atom<Model> {
  private let accessQueue = DispatchQueue(label: "Prelude.Atom<\(Model.self)>")
  private var value: Model
  private var observers: [ObserverId:(Model) -> ()] = [:]
  
  init(_ initial: Model) {
    value = initial
  }
}

public extension Atom {
  
  func update<A>(with modify: @escaping (inout Model) throws -> A) -> Async<A> {
    return Async(queue: accessQueue) {
      let result = try modify(&self.value)
      for observer in self.observers.values {
        DispatchQueue.global().async { [value = self.value] in
          observer(value)
        }
      }
      return result
    }.transferred(to: DispatchQueue.global())
  }
  
  func notify(observer: @escaping (Model) -> ()) -> ObserverId {
    let id = ObserverId()
    accessQueue.async { [value] in
      self.observers[id] = observer
      DispatchQueue.global().async { [value] in
        observer(value)
      }
    }
    return id
  }
  
  func removeObserver(id: ObserverId) {
    accessQueue.async {
      self.observers[id] = nil
    }
  }
  
}

public extension Atom {
  
  struct ObserverId {
    private let id = UUID()
  }
  
}

extension Atom.ObserverId: Hashable {
  
  public static func == (lhs: Atom.ObserverId, rhs: Atom.ObserverId) -> Bool {
    return lhs.id == rhs.id
  }
  
  public var hashValue: Int {
    return id.hashValue
  }

}
