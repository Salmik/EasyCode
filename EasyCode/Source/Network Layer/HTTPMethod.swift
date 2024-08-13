//
//  HTTPMethod.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

/// `HTTPMethod` is an enumeration that represents the various HTTP methods that can be used in a network request.
/// Each case corresponds to a specific HTTP method, with its associated string value.
public enum HTTPMethod: String {

    /// The `GET` method requests a representation of the specified resource.
    /// Requests using `GET` should only retrieve data.
    case get = "GET"

    /// The `POST` method is used to submit an entity to the specified resource, often causing a change in state
    /// or side effects on the server.
    case post = "POST"

    /// The `PUT` method replaces all current representations of the target resource with the request payload.
    case put = "PUT"

    /// The `PATCH` method is used to apply partial modifications to a resource.
    case patch = "PATCH"

    /// The `HEAD` method asks for a response identical to a `GET` request, but without the response body.
    case head = "HEAD"

    /// The `DELETE` method deletes the specified resource.
    case delete = "DELETE"
}
