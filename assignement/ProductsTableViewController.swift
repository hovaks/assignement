//
//  ProductsTableViewController.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/12/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import UIKit

class ProductsTableViewController: UITableViewController {
	
	var filters = [String]() {
		didSet {
			print(filters)
		}
	}
	var products = [Product]() {
		didSet {
			tableView.reloadData()
		}
	}
	var searchInProgress = false
	
	var networkController: NetworkController?
	var searchController: UISearchController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.rowHeight = 100
		
		searchController = UISearchController(searchResultsController: nil)
		searchController.searchResultsUpdater = self
		searchController.searchBar.delegate = self
		searchController.searchBar.placeholder = "Search Products"
		searchController.dimsBackgroundDuringPresentation = false
		navigationItem.searchController = searchController
		definesPresentationContext = true
		
		
		networkController = NetworkController()
		
		networkController?.loadProducts(query: "", filters: ["Books", "Music"], sortBy: .name) { results in
			if let results = results {
				self.products = results
			}
		}
	}
	
	@IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
		navigationItem.searchController?.isActive = true
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
		//segue for the popover configuration window
		if segue.identifier == "PopOver" {
			if let controller = segue.destination as? FilterPopoverTableViewController {
				let width = self.view.bounds.width
				let height = self.view.bounds.height - self.view.bounds.height / 5
				controller.popoverPresentationController!.delegate = self
				controller.preferredContentSize = CGSize(width: width, height: height)
				controller.filters = filters
				controller.networkController = networkController
			}
		}
	}
}

extension ProductsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
	func updateSearchResults(for searchController: UISearchController) {
		let searchBar = searchController.searchBar
		if let query = searchBar.text {
			if !searchInProgress && query.count > 2 {
				searchInProgress = true
				networkController?.loadProducts(query: query, filters: nil, sortBy: .none) { results in
					if let results = results {
						self.searchInProgress = false
						self.products = results
					}
				}
			}
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		networkController?.loadProducts(query: "", filters: nil, sortBy: .none) { results in
			if let results = results {
				self.searchInProgress = false
				self.products = results
			}
		}
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
	}
}
