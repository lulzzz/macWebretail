//
//  CollectionViewItem.swift
//  macWebretail
//
//  Created by Gerardo Grisolini on 22/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
	
	@IBOutlet weak var numberText: NSTextFieldCell!
	@IBOutlet weak var amountText: NSTextFieldCell!
	@IBOutlet weak var causalText: NSTextFieldCell!
	@IBOutlet weak var descriptionText: NSTextFieldCell!
	@IBOutlet weak var deviceText: NSTextFieldCell!
	var id: Int32 = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()

		view.wantsLayer = true
		view.layer?.borderWidth = 1.0
		view.layer?.cornerRadius = 5
		view.layer?.borderColor = NSColor.lightGray.cgColor
		view.layer?.backgroundColor = NSColor.white.cgColor
    }

	 override var isSelected: Bool {
		didSet {
			view.layer?.borderWidth = isSelected ? 3.0 : 1.0
			Synchronizer.shared.movementId = isSelected ? id : 0
		}
	}
}
