//
//  Extensions.swift
//  macWebretail
//
//  Created by Gerardo Grisolini on 24/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import AppKit

extension Date {
	func formatDateInput() -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter.string(from: self as Date)
	}
	
	func formatDateShort() -> String {
		return formatDate(format: "yyyy-MM-dd")
	}
	
	func formatDate(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter.string(from: self as Date)
	}
}

extension String {
	func toShortDate() -> Date {
		return toDate(format: "yyyy-MM-dd")
	}
	
	func toDate(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter.date(from: self)!
	}
}

extension Double {
//	func roundCurrency() -> Double {
//		return (self * 100).rounded() / 100
//	}
	
	func formatCurrency() -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 2
		formatter.locale = Locale.current
		return formatter.string(from: self as NSNumber)!
	}
}

extension Sequence {
	func groupBy<G: Hashable>(closure: (Iterator.Element)->G) -> [G: [Iterator.Element]] {
		var results = [G: Array<Iterator.Element>]()
		forEach {
			let key = closure($0)
			if var array = results[key] {
				array.append($0)
				results[key] = array
			}
			else {
				results[key] = [$0]
			}
		}
		return results
	}
}

extension MovementArticle {
	mutating func setJSONValues(item: NSDictionary) {
		self.movementArticleBarcode = item["movementArticleBarcode"] as! String
		self.movementArticleQuantity = item["movementArticleQuantity"] as! Double
		self.movementArticlePrice = item["movementArticlePrice"] as! Double

		let product = item["movementArticleProduct"] as! NSDictionary
		var values = [Int:String]()
		for attribute in product["attributes"] as! [NSDictionary] {
			for attributeValue in attribute["attributeValues"] as! [NSDictionary] {
				let value = attributeValue["attributeValue"] as! NSDictionary
				values.updateValue(value["attributeValueName"] as! String, forKey: value["attributeValueId"] as! Int)
			}
		}
		self.movementArticleProduct = ""
		for article in product["articles"] as! [NSDictionary] {
			for attributeValue in article["attributeValues"] as! [NSDictionary] {
				let value = values[attributeValue["attributeValueId"] as! Int]
				self.movementArticleProduct.append("\(value!) ")
			}
		}
	}
}
