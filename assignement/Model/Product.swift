//
//  Product.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/12/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import Foundation
import UIKit

enum Sort: String {
	case none = "none"
	case name = "name"
	case price = "price"
}

struct Product: Decodable {
	let name: String
	let price: Double
	let image: String
	let category: Category
}
	
	let imageCache = NSCache<NSString, UIImage>()
	
	extension UIImageView {
		
		func imageFromServerURL(_ URLString: String) {
			
			self.image = nil
			if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
				self.image = cachedImage
				return
			}
			
			if let url = URL(string: URLString) {
				URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
					
					DispatchQueue.main.async {
						if let data = data {
							if let downloadedImage = UIImage(data: data) {
								imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
								self.image = downloadedImage
							}
						}
					}
				}).resume()
			}
		}
	}
