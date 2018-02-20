//
//  Weak.swift
//  Prelude
//
//  Created by Kristofer Hanes on 2018-01-20.
//  Copyright © 2018 Kristofer Hanes. All rights reserved.
//

final class Weak<Wrapped: AnyObject> {
  weak var unwrapped: Wrapped?
  
  init(_ ref: Wrapped) {
    self.unwrapped = ref
  }
}
