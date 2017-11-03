//
//  Monoid.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/20/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

public protocol Semigroup {
  static func combine(_ lhs: Self, _ rhs: Self) -> Self
}

public protocol Monoid: Semigroup {
  static var identity: Self { get }
}

extension Optional: Monoid {
  
  public static var identity: Wrapped? {
    return nil
  }
  
  public static func combine(_ lhs: Wrapped?, _ rhs: Wrapped?) -> Wrapped? {
    return lhs ?? rhs
  }
  
}

extension Array: Monoid {
  
  public static var identity: [Element] {
    return []
  }
  
  public static func combine(_ lhs: [Element], _ rhs: [Element]) -> [Element] {
    return lhs + rhs
  }
  
}
