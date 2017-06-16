//
//  JsonResource.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/15/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

import Foundation

struct JsonResource<Loaded> {
  let url: URL
  let reader: JsonReader<Loaded>
}

extension JsonResource {
  
  func map<Mapped>(_ transform: @escaping (Loaded) throws -> Mapped) -> JsonResource<Mapped> {
    return JsonResource<Mapped>(
      url: url,
      reader: JsonReader { json in
        return try transform(self.reader.reading(from: json))
      }
    )
  }
  
  var loaded: Callback<Loaded> {
    return Callback { yield in
      URLSession.shared.dataTask(with: self.url) { data, _, error in
        switch (data, error) {
        case let (.some(data), .none):
          do {
            yield(.ok(try self.reader.reading(from: Json(data: data))))
          }
          catch {
            yield(.error(error))
          }
        case let (_, .some(error)):
          yield(.error(error))
        default:
          fatalError()
        }
        }.resume()
    }
  }
  
}
