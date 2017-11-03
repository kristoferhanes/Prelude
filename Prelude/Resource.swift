//
//  Resource.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/15/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

import Foundation

public struct Resource<Loaded> {
  let url: URL
  let reader: Reader<Data, Loaded>
}

public extension Resource {
  
  init(url: URL, reader: JsonReader<Loaded>) {
    self.url = url
    self.reader = reader.contramap(Json.init)
  }
  
}

public extension Resource { // Functor
  
  func map<Mapped>(_ transform: @escaping (Loaded) throws -> Mapped) -> Resource<Mapped> {
    return Resource<Mapped>(url: url, reader: reader.map(transform))
  }
  
}
