//
//  BusinessModel.swift
//  Prelude
//
//  Created by Kristofer Hanes on 2017-11-26.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

public protocol BusinessModel {
  associatedtype Event
  associatedtype Command
  init()
  func event(for command: Command) -> Event
  mutating func update(with event: Event)
}
