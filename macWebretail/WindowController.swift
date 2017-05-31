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
    var task: Process = Process()

	override func windowDidLoad() {
        super.windowDidLoad()
				
        let icon = NSImage.init(named: "statusIcon")
		//icon?.isTemplate = true // best for dark mode
		statusItem.image = icon
		statusItem.title = "Webretail"
		statusItem.menu = statusMenu
		
		Synchronizer.shared.iCloudUserIDAsync()
    }
    
	@IBAction func dashboardClicked(_ sender: NSMenuItem) {
		self.window?.orderFront(self)
	}
	
	@IBAction func quitClicked(_ sender: NSMenuItem) {
        task.interrupt()
        task.terminate()
		NSApplication.shared().terminate(self)
	}
	
	@IBAction func refreshClicked(_ sender: Any) {
		let viewController = self.contentViewController as! ViewController
		viewController.reloadData()
	}

	@IBAction func settingsClicked(_ sender: Any) {
		self.window?.close()
	}
	
	@IBAction func barcodeClicked(_ sender: Any) {
		if Synchronizer.shared.movementId == 0 || Synchronizer.shared.isSyncing {
			return
		}
		
		DispatchQueue.global(qos: .background).async {
			
			Synchronizer.shared.getBarcodes()
			
			if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
				
				let document = PDFDocument()
				for item in Synchronizer.shared.movementArticles {
					for _ in 0..<Int(item.movementArticleQuantity) {
						let page = BarcodePDFPage(
							title: item.movementArticleProduct,
							price: item.movementArticlePrice.formatCurrency(),
							barcode: item.movementArticleBarcode
						)
						document.insert(page, at: 0)
					}
				}
				
				let path = URL(fileURLWithPath: dir).appendingPathComponent("barcode.pdf")
				try? FileManager.default.removeItem(at: path)
				document.write(to: path)
				
				NSWorkspace.shared().open(path)
			} else {
				print("Path format incorrect.")
			}
         }
	}
    
    @IBAction func startStopWebretail(_ sender: NSMenuItem) {
        if sender.title == "Start server" {
            task = Process()
            task.currentDirectoryPath = "/Users/gerardogrisolini/Projects/github.com/Webretail"
            task.launchPath = "\(self.task.currentDirectoryPath)/.build/debug/Webretail"
            task.arguments = []
            task.launch()

            sender.title = "Stop server"
            sender.image = NSImage.init(named: "NSStatusAvailable")
       } else {
            task.interrupt()
            task.terminate()
            
            sender.title = "Start server"
            sender.image = NSImage.init(named: "NSStatusUnavailable")
        }
    }

    @IBAction func openHome(_ sender: NSMenuItem) {
        let path = URL(string: "http://localhost:8181/")!
        NSWorkspace.shared().open(path)
    }
}
