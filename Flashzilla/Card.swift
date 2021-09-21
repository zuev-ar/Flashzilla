//
//  Card.swift
//  Flashzilla
//
//  Created by Arkasha Zuev on 16.09.2021.
//

import Foundation

struct Card {
    let prompt: String
    let answer: String
    
    static var example: Card {
        Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
    }
}
