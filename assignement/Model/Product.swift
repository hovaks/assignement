//
//  Product.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/12/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import Foundation

enum Sort: String {
	case none = "none"
	case name = "name"
	case price = "price"
}

struct Product: Decodable {
	let name: String
	let price: Double
	let image: [String]
	let category: [Category]
}
