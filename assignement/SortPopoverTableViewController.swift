//
//  SortTableViewController.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/12/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import UIKit

class SortPopoverTableViewController: UITableViewController {
	var sortValue: Sort! = .none
	var values = ["none", "name", "price" ]
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return values.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath)
		cell.textLabel?.text = values[indexPath.row].capitalized
		
		if values[indexPath.row] == sortValue.rawValue {
			cell.accessoryType = .checkmark
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		for cell in tableView.visibleCells {
			cell.accessoryType = .none
		}
		
		if let cell = tableView.cellForRow(at: indexPath) {
			cell.accessoryType = .checkmark
			sortValue = Sort(rawValue: (values[indexPath.row]))
		}
	}
}
