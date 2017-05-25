//
//  HeaderView.swift
//  macWebretail
//
//  Created by Gerardo Grisolini on 22/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import Cocoa

class HeaderView: NSView {

	@IBOutlet weak var headerText: NSTextField!
	@IBOutlet weak var headerCount: NSTextField!
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
		NSColor(calibratedWhite: 0.8 , alpha: 0.8).set()
		NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.sourceOver)
    }
}
