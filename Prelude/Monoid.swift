//
//  Monoid.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/20/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

protocol Semigroup {
  static func combine(_: Self, _: Self) -> Self
}

protocol Monoid: Semigroup {
  static var identity: Self { get }
}
