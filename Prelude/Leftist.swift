//
//  Leftist.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/8/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

indirect enum Leftist<Element: Comparable> {
  case leaf
  case branch(Leftist, Element, Leftist, Int)
}

extension Leftist {
  
  init() {
    self = .leaf
  }
  
  init(_ value: Element) {
    self.init(left: .leaf, element: value, right: .leaf)
  }
  
  private init(left: Leftist, element: Element, right: Leftist) {
    self = .branch(left, element, right, right.rank + 1)
  }
  
  func merged(with other: Leftist) -> Leftist {
    switch (self, other) {
    case let (.leaf, tree): return tree
    case let (tree, .leaf): return tree
    case let (.branch(_, e1, _, _), .branch(_, e2, _, _)) where e1 > e2:
      return other.merged(with: self)
    case let (.branch(left, element, right, _), _):
      let newRight = right.merged(with: other)
      if left.rank >= newRight.rank {
        return Leftist(
          left: left,
          element: element,
          right: newRight
        )
      }
      else {
        return Leftist(
          left: newRight,
          element: element,
          right: left
        )
      }
    default:
      fatalError("This should never happen.")
    }
  }
  
  func inserting(_ newElement: Element) -> Leftist {
    return merged(with: Leftist(newElement))
  }
  
  func next() -> (Element, Leftist)? {
    guard case let .branch(l, e, r, _) = self else { return nil }
    return (e, l.merged(with: r))
  }
  
  var view: Element? {
    guard case let .branch(_, e, _, _) = self else { return nil }
    return e
  }
  
  private var rank: Int {
    guard case let .branch(_, _, _, r) = self else { return 0 }
    return r
  }
  
}
