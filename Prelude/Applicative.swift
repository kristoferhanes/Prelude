//
//  Applicative.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/8/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

precedencegroup ApplicativePrecedence {
  associativity: left
  higherThan:    MonadPrecedence
  lowerThan:     NilCoalescingPrecedence
}

precedencegroup DroppingApplicativePrecedence {
  associativity: left
  higherThan:    ApplicativePrecedence
  lowerThan:     NilCoalescingPrecedence
}

infix operator <^> : ApplicativePrecedence
infix operator <*> : ApplicativePrecedence
infix operator <*  : DroppingApplicativePrecedence
infix operator  *> : DroppingApplicativePrecedence

func fst<A, B>(_ a: A) -> (B) -> A {
  return { _ in a }
}

func snd<A, B>(_: A) -> (B) -> B {
  return { b in b }
}

