//
//  ViewController.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/11/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginContainer: UIView!
	
	var networkController: NetworkController?
	let defaults = UserDefaults.standard
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let _ = defaults.object(forKey: "accessToken") as? String {
			loginContainer.isHidden = true
		}
	}
	
	func presentProducts() {
		if let _ = defaults.object(forKey: "accessToken") as? String {
			if let productsVC = storyboard?.instantiateViewController(withIdentifier: "ProductsVC") as? UINavigationController {
				emailTextField.text = nil
				passwordTextField.text = nil
				present(productsVC, animated: false) {
					self.loginContainer.isHidden = false
				}
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		presentProducts()
	}
	
	@IBAction func loginButtonTapped(_ sender: UIButton) {
		networkController = NetworkController()
		//Authorization
		guard
			let email = emailTextField.text,
			let password = passwordTextField.text
			else {
				return
		}
		
		networkController?.authroize(
		withEmail: email,
		password: password) {
			self.networkController = nil
			self.presentProducts()
		}
	}
}

