//
//  BusinessModel.swift
//  Prelude
//
//  Created by Kristofer Hanes on 2017-11-26.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

public protocol BusinessModel {
  associatedtype Message
  associatedtype Event
  init()
  func events(for message: Message) -> [Event]
  mutating func update(with event: Event)
}

public extension BusinessModel {
  
  mutating func send(_ message: Message) {
    for event in events(for: message) {
      update(with: event)
    }
  }
  
}
