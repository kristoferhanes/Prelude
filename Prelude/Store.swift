//
//  Store.swift
//  Prelude
//
//  Created by Kristofer Hanes on 2017-11-29.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

struct Store<Index, Wrapped> {
  var index: Index
  private let inspect: (Index) -> Wrapped
}

extension Store { // Functor
  
  func map<Mapped>(_ transform: @escaping (Wrapped) -> Mapped) -> Store<Index, Mapped> {
    return Store<Index, Mapped>(index: index, inspect: inspect >>> transform)
  }
  
}

extension Store { // Comonad
  
  var extract: Wrapped {
    return inspect(index)
  }
  
  func extend<Extended>(_ resolve: @escaping (Store) -> Extended) -> Store<Index, Extended> {
    return Store<Index, Extended>(
      index: index,
      inspect: { [inspect] i in resolve(Store(index: i, inspect: inspect)) }
    )
  }
  
}
