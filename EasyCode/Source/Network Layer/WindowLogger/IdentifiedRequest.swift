//
//  IdentifiedRequest.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

import Foundation

struct IdentifiedRequest {

    var request: URLRequest
    let id: UUID

    init(request: URLRequest) {
        self.request = request
        self.id = UUID()
    }
}
