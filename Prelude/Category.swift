//
//  Category.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/17/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

precedencegroup CategoryPrecedence {
  associativity: right
  higherThan:    AssignmentPrecedence
}

infix operator >>> : CategoryPrecedence
infix operator <<< : CategoryPrecedence

public func >>> <A, B, C>(f: @escaping (A) throws -> B, g: @escaping (B) throws -> C) -> ((A) throws -> C) {
  return { a in try g(f(a)) }
}

public func <<< <A, B, C>(g: @escaping (B) throws -> C, f: @escaping (A) throws -> B) -> ((A) throws -> C) {
  return f >>> g
}

public func identity<A>(_ a: A) -> A {
  return a
}
