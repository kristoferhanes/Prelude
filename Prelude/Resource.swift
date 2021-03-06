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

public struct Resource<Decoded> {
  public let request: URLRequest
  fileprivate let decode: (Data) throws -> Decoded
  
  public func decoding(_ data: Data) throws -> Decoded {
    return try decode(data)
  }
}

public extension Resource where Decoded: Decodable {
  
  init(request: URLRequest) {
    self.init(request: request) { try JSONDecoder().decode(Decoded.self, from: $0) }
  }
  
  init(url: URL) {
    self.init(request: URLRequest(url: url))
  }
  
}

public extension Resource {
  
  func loadFromNetwork() -> Async<Decoded> {
    return URLSession.shared.data(request: request).map(decoding)
  }
  
}

public extension Resource { // Functor
  
  func map<Mapped>(_ transform: @escaping (Decoded) throws -> Mapped) -> Resource<Mapped> {
    return Resource<Mapped>(request: request, decode: decoding >>> transform)
  }
  
}

public extension Resource where Decoded: Decodable {

  func decoding(_ data: Data) throws -> Decoded {
    return try Resource<Decoded>(request: request).decoding(data)
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
