//
//  ResourceLoader.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/16/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

import Foundation

public struct ResourceLoader<Loaded> {
  private let load: (Resource<Loaded>) -> Async<Loaded>
  private let set: (Resource<Loaded>, Loaded) -> Async<()>
  
  init(load: @escaping (Resource<Loaded>) -> Async<Loaded>,
       set: @escaping (Resource<Loaded>, Loaded) -> Async<()>) {
    self.load = load
    self.set = set
  }
  
  func load(_ resource: Resource<Loaded>) -> Async<Loaded> {
    return load(resource)
  }
  
  func set(_ value: Loaded, for resource: Resource<Loaded>) -> Async<()> {
    return set(resource, value)
  }
}

public struct ResourceLoaderError: Error { }

extension ResourceLoader: Monoid {
  
  public static var identity: ResourceLoader {
    return ResourceLoader(
      load: { _ in
        return Async { yield in
          yield(.error(ResourceLoaderError()))
        }
    },
      set: { _, _ in
        return .pure(())
    })
  }
  
  public static func combine(_ lhs: ResourceLoader, _ rhs: ResourceLoader) -> ResourceLoader {
    return ResourceLoader(
      load: { resource in
        return Async { yield in
          lhs.load(resource).run { status in
            switch status {
            case let .ok(value):
              yield(.ok(value))
            case .error:
              rhs.load(resource).run { status in
                switch status {
                case let .ok(value):
                  lhs.set(value, for: resource).run { status in
                    switch status {
                    case .ok:
                      yield(.ok(value))
                    case let .error(error):
                      yield(.error(error))
                    }
                  }
                case let .error(error):
                  yield(.error(error))
                }
              }
            }
          }
        }
    },
      set: { resource, value in
        return lhs.set(value, for: resource)
          .then(rhs.set(value, for: resource))
    })
  }
  
}

public extension ResourceLoader {
  
  static func ?? (lhs: ResourceLoader, rhs: ResourceLoader) -> ResourceLoader {
    return combine(lhs, rhs)
  }
  
  static var fail: ResourceLoader {
    return identity
  }
  
}

public extension ResourceLoader {

  static var cache: ResourceLoader {
    var cache: [URL:Loaded] = [:]
    return ResourceLoader(
      load: { resource in
        return Async { yield in
          if let value = cache[resource.url] {
            yield(.ok(value))
          }
          else {
            yield(.error(ResourceLoaderError()))
          }
        }
    },
      set: { resource, value in
        return Async { yield in
          cache[resource.url] = value
          yield(.pure(()))
        }
    })
  }

  static var network: ResourceLoader {
    return ResourceLoader(
      load: { resource in
        return Async { yield in
          URLSession.shared.dataTask(with: resource.url) { data, _, error in
            switch (data, error) {
            case let (.some(data), .none):
              do {
                yield(.ok(try resource.reader.reading(from: data)))
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
        
    },
      set: { _, _ in
        return .pure(())
    })
  }
  
}
