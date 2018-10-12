//
//  NetworkController.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/12/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import Foundation

class NetworkController {
	
	let headers = [
		"content-type": "application/json",
		"x-apikey": "ce780d01229ecc62a0bf2bf078cac31fc2a57",
		"cache-control": "no-cache"
	]
	
	private let baseURL = "https://stdev-9df6.restdb.io/rest/"
	var currentTask: URLSessionTask?
	
	func loadCategories(completion: @escaping ([Category]?) -> Void) {
		let urlString = baseURL + "categories"
		guard let url = URL(string: urlString) else {
			completion(nil)
			return
		}
		
		let configuration = URLSessionConfiguration.ephemeral
		configuration.waitsForConnectivity = true
		
		let request = NSMutableURLRequest(url: url,
										  cachePolicy: .useProtocolCachePolicy,
										  timeoutInterval: 10.0)
		request.httpMethod = "GET"
		request.allHTTPHeaderFields = headers
		
		let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
		let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
			if (error != nil) {
				print(error)
			} else {
				guard let httpResponse = response as? HTTPURLResponse else { return }
				if httpResponse.statusCode == 200 {
					guard let data = data else { return }
					do {
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						let categories = try decoder.decode([Category].self, from: data)
						completion(categories)
					} catch let error {
						print(error as? Any)
					}
				}
			}
			session.finishTasksAndInvalidate()
		})
		
		dataTask.resume()
	}
	
	
	func loadProducts(query: String, filters: [String]?, sortBy sort: Sort, completion: @escaping ([Product]?) -> Void) {
		
		var urlString = baseURL + "products"

			var regex = ".*"
		if query != "" {
			regex = "/\(query)/"
		}
		urlString += "?q={\"name\": {\"$regex\" : \"\(regex)\"}}"

		//let filterString = ", {\"$or\": [{\"category\": {\"name\":\"Books\"}}, {\"category\": {\"name\":\"Music\"}}]}}"
		//urlString += filterString
		
		if sort != .none {
			urlString += "&sort=\(sort.rawValue)"
		}
		
		print(urlString)
			
		
		guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
			let url = URL(string: encodedURLString) else {
				completion(nil)
				return
		}
		
		let configuration = URLSessionConfiguration.ephemeral
		configuration.waitsForConnectivity = true
		
		let request = NSMutableURLRequest(url: url,
										  cachePolicy: .useProtocolCachePolicy,
										  timeoutInterval: 10.0)
		request.httpMethod = "GET"
		request.allHTTPHeaderFields = headers
		
		let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
		let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
			if (error != nil) {
				print(error)
			} else {
				guard let httpResponse = response as? HTTPURLResponse else { return }
				if httpResponse.statusCode == 200 {
					guard let data = data else { return }
					do {
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						let products = try decoder.decode([Product].self, from: data)
						completion(products)
					} catch let error {
						print(error as? Any)
					}
				}
			}
			session.finishTasksAndInvalidate()
		})
		
		dataTask.resume()
	}
}
