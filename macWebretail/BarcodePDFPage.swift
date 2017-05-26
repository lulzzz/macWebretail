//
//  BarcodePDFPage.swift
//  macWebretail
//
//  Created by Gerardo Grisolini on 26/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import Quartz

class BarcodePDFPage: PDFPage {
	
	let pdfWidth: CGFloat
	let pdfHeight: CGFloat
	let title: NSString
	let price: NSString
	let barcode: NSString
	
	init(title: String = "", price: String = "", barcode: String = "")
	{
		self.title = title as NSString
		self.price = price as NSString
		self.barcode = " \(barcode) " as NSString
		
		let image = barcode.toBarcode()!
		self.pdfWidth = image.size.width
		self.pdfHeight = image.size.height
		super.init(image: image)!
	}

	func drawText()
	{
		let titleParagraphStyle = NSMutableParagraphStyle()
		titleParagraphStyle.alignment = NSTextAlignment.left
		let titleFontAttributes = [
			NSFontAttributeName: NSFont.labelFont(ofSize: 20),
			NSParagraphStyleAttributeName: titleParagraphStyle,
			NSForegroundColorAttributeName: NSColor.black
		]
		let titleRect = NSMakeRect(CGFloat(26), pdfHeight - 40, pdfWidth - 150, 30)
		self.title.draw(in: titleRect, withAttributes: titleFontAttributes)
		
		let priceParagraphStyle = NSMutableParagraphStyle()
		priceParagraphStyle.alignment = NSTextAlignment.right
		let priceFontAttributes = [
			NSFontAttributeName: NSFont.labelFont(ofSize: 24),
			NSParagraphStyleAttributeName: titleParagraphStyle,
			NSForegroundColorAttributeName: NSColor.black
		]
		let priceRect = NSMakeRect(pdfWidth - 124, pdfHeight - 36, 100, 30)
		self.price.draw(in: priceRect, withAttributes: priceFontAttributes)
		
		let barcodeParagraphStyle = NSMutableParagraphStyle()
		barcodeParagraphStyle.alignment = NSTextAlignment.center
		let barcodeFontAttributes = [
			NSFontAttributeName: NSFont.labelFont(ofSize: 26),
			NSParagraphStyleAttributeName: barcodeParagraphStyle,
			NSForegroundColorAttributeName: NSColor.black,
			NSBackgroundColorAttributeName: NSColor.white
		]
		let barcodeRect = NSMakeRect(CGFloat(0), CGFloat(5), pdfWidth, 40)
		self.barcode.draw(in: barcodeRect, withAttributes: barcodeFontAttributes)
	}
	
	//	override func draw(with box: PDFDisplayBox, to context: CGContext) {
	//		super.draw(with: box, to: context)
	//		self.drawText()
	//	}
	
	override func draw(with box: PDFDisplayBox) {
		super.draw(with: box)
		self.drawText()
	}
}
