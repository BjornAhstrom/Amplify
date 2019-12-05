//
//  Person.swift
//  amplifyTest
//
//  Created by Björn Åhström on 2019-12-04.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import Foundation

struct Persons {
    var persons: [Person] = []
}

struct Person {
    let id: String?
    let name: String?
    let description: String?
}
