//
//  NetworkController.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/12/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import UIKit
import Alamofire

class NetworkController {
	
	var accessToken: String?
	
	var headers = ["content-type": "application/json"]
	private let baseURL = "http://142.93.143.76"
	
	init(withToken token: String? = nil) {
		if let token = token {
			self.accessToken = token
			headers["Authorization"] = "Bearer \(token)"
		}
	}
	
	//Authorize
	func authroize(
		withEmail email: String,
		password: String,
		completion: @escaping (Int?) -> Void) {
		
		//Create Payload
		let urlString = baseURL + "/auth/login"
		guard let url = URL(string: urlString) else {
			return
		}
		
		let parameters: [String: Any] = [
			"username": email,
			"password": password
		]
		
		//Create Connection
		Alamofire.request(url,
						  method: .post,
						  parameters: parameters,
						  encoding: JSONEncoding.default,
						  headers: headers)
			.responseData { response in
				switch response.result {
				case .success:
					guard
						let data = response.data,
						let statusCode = response.response?.statusCode
						else { return completion(nil) }
					do {
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						
						//Serialize Token
						let token = try decoder.decode(AccessToken.self, from: data)
						UserDefaults.standard.set(token.accessToken, forKey: "accessToken")
						return completion(statusCode)
					} catch {
						return completion(statusCode)
					}
				case .failure:
					return completion(nil)
				}
		}
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
		
		Alamofire.request(url,
						  method: .get,
						  parameters: nil,
						  encoding: JSONEncoding.default,
						  headers: headers)
			.responseData { response in
				switch response.result {
				case .success:
					guard
						let data = response.data
						else { return completion(nil) }
					do {
						//Serialize Products
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						let categories = try decoder.decode([Category].self, from: data)
						return completion(categories)
					} catch {
						return completion(nil)
					}
					
				case.failure:
					return completion(nil)
				}
		}
	}
	
	//Get Products
	func loadProducts(
		query: String,
		filters: [Int],
		sortBy sort: Sort,
		completion: @escaping ([Product]?) -> Void)
	{
		
		guard
			let url = generateURL(query: query,
								  filters: filters,
								  sort: sort)
			else {
				return completion(nil)
		}
		
		Alamofire.request(url,
						  method: .get,
						  parameters: nil,
						  encoding: JSONEncoding.default,
						  headers: headers)
			.responseData { response in
				switch response.result {
				case .success:
					guard
						let data = response.data
						else { return completion(nil) }
					do {
						//Serialize Products
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						let products = try decoder.decode([Product].self, from: data)
						completion(products)
					} catch{
						return completion(nil)
					}
				case.failure:
					return completion(nil)
				}
		}
	}
	
	//Private Helper Functions
	private func generateURL(query: String,
							 filters: [Int],
							 sort: Sort) -> URL? {
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
		
		//Encode URL
		guard
			let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
			let url = URL(string: encodedURLString)
			else {
				return nil
		}
		
		return url
	}
}
