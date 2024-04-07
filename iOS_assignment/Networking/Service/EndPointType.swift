//
//  EndPointType.swift
//  iOS_assignment
//
//  Created by Yasir Khan on 05/04/2024.
//

import Foundation

protocol EndPointType {
    var baseUrl : URL { get }
    var path : String { get }
    var httpMethod : HTTPMethod { get }
    var task : HTTPTask  { get }
    var headers : String? { get }
}
