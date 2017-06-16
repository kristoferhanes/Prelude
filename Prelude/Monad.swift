//
//  Monad.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/16/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

precedencegroup MonadPrecedence {
  associativity: left
}

infix operator >>- : MonadPrecedence
