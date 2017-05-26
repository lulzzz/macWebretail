//
//  WindowTitleless.swift
//  macWebretail
//
//  Created by Gerardo Grisolini on 25/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import Cocoa

class WindowTitleless: NSWindow {

	override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
		super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
		
		self.titleVisibility = .hidden
	}
}
