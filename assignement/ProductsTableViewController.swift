//
//  ProductsTableViewController.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/12/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import UIKit

class ProductsTableViewController: UITableViewController {
	var searchValue: String = "" {
		didSet {
			loadProducts()
		}
	}
	var sortValue: Sort = .none {
		didSet {
			loadProducts()
		}
	}
	var filters = [Int]() {
		didSet {
			loadProducts()
		}
	}
	var products = [Product]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	var categories = [Category]()
	
	
	var searchInProgress = false
	let defaults = UserDefaults.standard
	var networkController: NetworkController?
	var searchController: UISearchController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.rowHeight = 100
		
		//Get Token and Set Network Controller
		let token = defaults.value(forKey: "accessToken") as? String
		networkController = NetworkController(withToken: token)
		
		loadProducts()
		
		//Configure SearchBar
		searchController = UISearchController(searchResultsController: nil)
		searchController.searchResultsUpdater = self
		searchController.searchBar.delegate = self
		searchController.delegate = self
		searchController.searchBar.placeholder = "Search Products"
		searchController.dimsBackgroundDuringPresentation = false
		navigationItem.searchController = searchController
		definesPresentationContext = true
	}
	@IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
		defaults.set(nil, forKey: "accessToken")
		self.dismiss(animated: false)
	}
	
	@IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
		navigationItem.searchController?.isActive = true
	}
	
	private func loadProducts() {
		networkController?.loadProducts(
			query: searchValue,
			filters: filters,
			sortBy: sortValue) { results in
				if let results = results {
					self.searchInProgress = false
					self.products = results
				}
		}
		
		networkController?.loadCategories { results in
			if let results = results {
				self.categories = results
			}
		}
	}
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return products.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let product = products[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
		
		if let productCell = cell as? ProductTableViewCell {
			productCell.product = product
		}
		
		return cell
	}
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		//Default Row Size
		let rowSize = 44
		
		//segue for the popover configuration window
		if segue.identifier == "FilterPopover" {
			if !categories.isEmpty {
				if let controller = segue.destination as? FilterPopoverTableViewController {
					let width = self.view.bounds.width
					let height = CGFloat(categories.count * rowSize)
					controller.popoverPresentationController!.delegate = self
					controller.preferredContentSize = CGSize(width: width, height: height)
					controller.filters = filters
					controller.categories = categories
				}
			}
		}
		
		if segue.identifier == "SortPopover" {
			if let controller = segue.destination as? SortPopoverTableViewController {
				let width = self.view.bounds.width
				let height = CGFloat(Sort.allCases.count * rowSize)
				controller.popoverPresentationController!.delegate = self
				controller.preferredContentSize = CGSize(width: width, height: height)
				controller.sortValue = sortValue
			}
		}
	}
}

extension ProductsTableViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
	
	func didPresentSearchController(_ searchController: UISearchController) {
		DispatchQueue.main.async {
			searchController.searchBar.becomeFirstResponder()
		}
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		let searchBar = searchController.searchBar
		if let query = searchBar.text {
			if !searchInProgress && query.count > 2 {
				searchValue = query
				searchInProgress = true
				loadProducts()
			}
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchValue = ""
		loadProducts()
	}
}

extension ProductsTableViewController: UIPopoverPresentationControllerDelegate {
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
	
	func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
		if let sender = popoverPresentationController.presentedViewController as? FilterPopoverTableViewController {
			filters = sender.filters
		}
		if let sender = popoverPresentationController.presentedViewController as? SortPopoverTableViewController {
			sortValue = sender.sortValue
		}
	}
}
