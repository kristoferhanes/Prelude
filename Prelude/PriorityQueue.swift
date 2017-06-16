//
//  PriorityQueue.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/10/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

struct PriorityQueue<Element: Comparable> {
  fileprivate var leftist: Leftist<Element>
}

extension PriorityQueue {
  
  init() {
    leftist = Leftist<Element>()
  }
  
  init<S: Sequence>(_ sequence: S) where S.Iterator.Element == Element {
    leftist = sequence.reduce(Leftist<Element>()) { $0.inserting($1) }
  }
  
  var peek: Element? {
    return leftist.view
  }
  
  mutating func enqueue(_ newElement: Element) {
    leftist = leftist.inserting(newElement)
  }
  
  mutating func dequeue() -> Element? {
    guard let (element, newLefist) = leftist.next() else { return nil }
    leftist = newLefist
    return element
  }
  
}
