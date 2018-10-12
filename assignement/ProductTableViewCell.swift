//
//  ProductTableViewCell.swift
//  assignement
//
//  Created by Hovak Davtyan on 10/12/18.
//  Copyright © 2018 Hovak Davtyan. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
	@IBOutlet weak var productImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	
	var product: Product! {
		didSet {
			setup(with: product)
		}
	}
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
		productImageView.image = UIImage()
		nameLabel.text = ""
		categoryLabel.text = ""
		priceLabel.text = ""
	}
	
	private func setup(with product: Product) {
		
		var baseURLString = "https://stdev-9df6.restdb.io/media/"
		baseURLString += product.image.first!
		
		self.productImageView?.imageFromServerURL(baseURLString)
		nameLabel.text = product.name
		categoryLabel.text = product.category.first?.name
		priceLabel.text = "\(product.price)$"
	}

}
