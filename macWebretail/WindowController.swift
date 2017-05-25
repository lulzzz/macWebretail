//
//  WindowController.swift
//  macWebretail
//
//  Created by Gerardo Grisolini on 24/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import Cocoa
import Quartz

class WindowController: NSWindowController {
	
	@IBOutlet weak var statusMenu: NSMenu!

	let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

	override func windowDidLoad() {
        super.windowDidLoad()
		
		let icon = NSImage.init(named: "statusIcon")
		//icon?.isTemplate = true // best for dark mode
		statusItem.image = icon
		//statusItem.title = "Webretail"
		statusItem.menu = statusMenu
		
		Synchronizer.shared.iCloudUserIDAsync()
    }

	@IBAction func showClicked(_ sender: NSMenuItem) {
		self.window?.orderFront(self)
	}
	
	@IBAction func quitClicked(_ sender: NSMenuItem) {
		NSApplication.shared().terminate(self)
	}
	
	@IBAction func refreshClicked(_ sender: Any) {
		let viewController = self.contentViewController as! ViewController
		viewController.reloadData()
	}

	@IBAction func closeClicked(_ sender: Any) {
		self.window?.close()
	}
	
	@IBAction func barcodeClicked(_ sender: NSToolbarItem) {
		if Synchronizer.shared.movementId == 0 || Synchronizer.shared.isSyncing {
			return
		}
		
		DispatchQueue.global(qos: .background).async {
			
			Synchronizer.shared.getBarcodes()
			
			self.generatePdf()
		}
	}

	func generateBarcode(from string: String) -> NSImage? {
		let data = string.data(using: String.Encoding.ascii)
		
		if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
			filter.setValue(data, forKey: "inputMessage")
			let transform = CGAffineTransform(scaleX: 4, y: 4)
			
			if let output = filter.outputImage?.applying(transform) {
				let rep = NSCIImageRep(ciImage: output)
				let nsImage = NSImage(size: rep.size)
				//let nsImage = NSImage(size: NSSize(width: self.collectionView.bounds.width - 40, height: 100.0))
				nsImage.addRepresentation(rep)
				
				return nsImage
			}
		}
		
		return nil
	}
	
	func generatePdf() {
		if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
			
			let document = PDFDocument()
			for item in Synchronizer.shared.movementArticles {
				for _ in 0..<Int(item.movementArticleQuantity) {
					let page = PDFPage(image: self.generateBarcode(from: item.movementArticleBarcode)!)
					document.insert(page!, at: 0)
				}
			}
			
			let path = NSURL(fileURLWithPath: dir).appendingPathComponent("barcode.pdf")!
			document.write(to: path)
			
			NSWorkspace.shared().open(path)
		} else {
			print("Path format incorrect.")
		}
	}
}
