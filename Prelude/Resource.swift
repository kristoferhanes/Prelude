//
//  Resource.swift
//  Prelude
//
//  Created by Kristofer Hanes on 2017-11-19.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

import struct Foundation.URLRequest
import struct Foundation.URL
import struct Foundation.Data
import class  Foundation.JSONDecoder
import class  Foundation.URLSession
import class  Foundation.HTTPURLResponse
import class  Foundation.NSError

public protocol Resource {
  associatedtype Decoded
  var request: URLRequest { get }
  func decoding(_ data: Data) throws -> Decoded
}

public struct AnyResource<Decoded>: Resource {
  public let request: URLRequest
  fileprivate let decode: (Data) throws -> Decoded
  
  public func decoding(_ data: Data) throws -> Decoded {
    return try decode(data)
  }
}

public extension AnyResource {
  
  init<R>(_ resource: R) where R: Resource, R.Decoded == Decoded {
    request = resource.request
    decode = resource.decoding
  }
  
}

public extension Resource {
  
  func loadFromNetwork() -> Async<Decoded> {
    return URLSession.shared.data(request: request).map(decoding)
  }
  
}

public extension Resource { // Functor
  
  func map<Mapped>(_ transform: @escaping (Decoded) throws -> Mapped) -> AnyResource<Mapped> {
    return AnyResource<Mapped>(request: request, decode: { data in try transform(self.decoding(data)) })
  }
  
}

public extension Resource where Decoded: Decodable {

  func decoding(_ data: Data) throws -> Decoded {
    let decoder = JSONDecoder()
    return try decoder.decode(Decoded.self, from: data)
  }
  
}

private extension URLSession {
  
  func data(request: URLRequest) -> Async<Data> {
    return Async { yield in
      URLSession.shared.dataTask(with: request) { data, response, error in
        switch (data, response, error) {
        case let (_, _, error?):
          yield(.error(error))
        case let (data?, _, nil):
          yield(.ok(data))
        case let (nil, response?, nil):
          guard let httpResponse = response as? HTTPURLResponse else { fatalError() }
          let error = NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: httpResponse.allHeaderFields as? [String : Any])
          yield(.error(error))
        default:
          fatalError()
        }
        }.resume()
    }
  }
  
}
