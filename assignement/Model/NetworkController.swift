//
//  NetworkController.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/12/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import UIKit

class NetworkController {
	
	var accessToken: String?
	var headers = ["content-type": "application/json"]
	
	init(withToken token: String? = nil) {
		if let token = token {
			self.accessToken = token
			headers["Authorization"] = "Bearer \(token)"
		}
	}
	
	private let baseURL = "http://142.93.143.76"
	
	//Authorize
	func authroize(
		withEmail email: String,
		password: String,
		completion: @escaping ()->()) {
		
		//Create Payload
		let urlString = baseURL + "/auth/login"
		guard let url = URL(string: urlString) else {
			return
		}
		
		let json: [String: Any] = [
			"username": email,
			"password": password
		]
		
		let jsonData = try? JSONSerialization.data(withJSONObject: json)
		
		//Create Connection
		let configuration = URLSessionConfiguration.ephemeral
		configuration.waitsForConnectivity = true
		
		let request = NSMutableURLRequest(url: url,
										  cachePolicy: .useProtocolCachePolicy,
										  timeoutInterval: 10.0)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = headers
		request.httpBody = jsonData
		
		let session = URLSession(
			configuration: configuration,
			delegate: nil,
			delegateQueue: OperationQueue.main)
		let dataTask = session.dataTask(
			with: request as URLRequest,
			completionHandler: { (data, response, error) -> Void in
			if (error != nil) {
				print(error as Any)
			} else {
				guard let httpResponse = response as? HTTPURLResponse else { return }
				switch httpResponse.statusCode {
				case 200:
					guard let data = data else { return }
					do {
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						let token = try decoder.decode(AccessToken.self, from: data)
						let defaults = UserDefaults.standard
						defaults.set(token.accessToken, forKey: "accessToken")
						completion()
					} catch let error {
						print(error)
					}
				case 401, 422:
					print("Login Failed")
				default:
					print("Other Error")
				}
			}
			session.finishTasksAndInvalidate()
		})
		
		dataTask.resume()
	}
	
	//Get Categories
	func loadCategories(
		completion: @escaping ([Category]?) -> Void)
	{
		let urlString = baseURL + "/categories"
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
		
		let session = URLSession(
			configuration: configuration,
			delegate: nil,
			delegateQueue: OperationQueue.main)
		let dataTask = session.dataTask(
			with: request as URLRequest,
			completionHandler: { (data, response, error) -> Void in
			if (error != nil) {
				print(error as Any)
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
						print(error)
					}
				}
			}
			session.finishTasksAndInvalidate()
		})
		
		dataTask.resume()
	}
	
	//Get Products
	func loadProducts(
		query: String,
		filters: [Int],
		sortBy sort: Sort,
		completion: @escaping ([Product]?) -> Void)
	{
		//Construct URL
		var urlString = baseURL + "/products?search=\(query)"
		
		if !filters.isEmpty {
			urlString += "&category="
			for filter in filters {
				urlString += "\(filter),"
			}
		}
		
		if sort != .none {
			urlString += "&order=\(sort.rawValue)"
		}
		
		//Get Data
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
		
		let session = URLSession(
			configuration: configuration,
			delegate: nil,
			delegateQueue: OperationQueue.main)
		let dataTask = session.dataTask(
			with: request as URLRequest,
			completionHandler: { (data, response, error) -> Void in
			if (error != nil) {
				print(error as Any)
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
						print(error)
					}
				}
			}
			session.finishTasksAndInvalidate()
		})
		
		dataTask.resume()
	}
}
