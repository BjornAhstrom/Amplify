//
//  Person.swift
//  TestingAmplify
//
//  Created by Björn Åhström on 2019-12-16.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import Foundation
import AWSMobileClient
import AWSAppSync

class Person {    
    var id: String
    var name: String
    var surname: String?
    var languages: [Language] = []
    
    init(id: String, name: String, surname: String, languages: [Language]) {
        self.id = id
        self.name = name
        self.surname = surname
        self.languages = languages
    }
    
}
