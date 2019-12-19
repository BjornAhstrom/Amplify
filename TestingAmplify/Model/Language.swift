//
//  Type.swift
//  amplifyTest
//
//  Created by Björn Åhström on 2019-12-04.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import Foundation
import AWSMobileClient
import AWSAppSync

class Language: CustomStringConvertible, Codable {
   
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.type == rhs.type
    }
    
    static func < (lhs: Language, rhs: Language) -> Bool {
        return lhs.type < rhs.type
    }
    
    let id: GraphQLID!
    let type: String
    var description: String { return type }
    
    init(id: GraphQLID, type: String) {
        self.id = id
        self.type = type
    }
}
