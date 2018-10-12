//
//  PopoverTableViewController.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/12/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import UIKit

class FilterPopoverTableViewController: UITableViewController {
	
	var categories = [Category]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	var filters = [String]()
	
	var networkController: NetworkController?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		networkController?.loadCategories { results in
			if let results = results {
				self.categories = results
			}
		}
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

		let catigoryName = categories[indexPath.row].name
        cell.textLabel?.text = catigoryName
		
		if filters.contains(catigoryName) {
			cell.accessoryType = .checkmark
		}
		

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		filters.append(categories[indexPath.row].name)
		tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
	}
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		filters.removeAll { $0 == categories[indexPath.row].name }
		tableView.cellForRow(at: indexPath)?.accessoryType = .none
	}
}
