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
	
    @IBOutlet weak var statusServer: NSMenuItem!
	@IBOutlet weak var statusMenu: NSMenu!

	let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let server: ServerController = ServerController()
    
	override func windowDidLoad() {
        super.windowDidLoad()
				
        let icon = NSImage.init(named: "statusIcon")
		//icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
		
        syncStatus()

        Synchronizer.shared.iCloudUserIDAsync()
    }
        
	@IBAction func dashboardClicked(_ sender: NSMenuItem) {
		self.window?.orderFront(self)
	}
	
	@IBAction func quitClicked(_ sender: NSMenuItem) {
        if server.isRunning {
            if dialogOKCancel(question: "Stop the server ?", text: "Otherwise the server will be ready.") {
                server.stop()
            }
        }
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
    
    @IBAction func startWebretail(_ sender: NSMenuItem) {
        server.start()
        syncStatus()
    }

    @IBAction func stopWebretail(_ sender: NSMenuItem) {
        server.stop()
        syncStatus()
    }

    @IBAction func openHome(_ sender: NSMenuItem) {
        let path = URL(string: "http://localhost:8181/")!
        NSWorkspace.shared().open(path)
    }
    
    func syncStatus() {
        if server.isRunning {
            statusServer.image = NSImage.init(named: "NSStatusAvailable")
        } else {
            statusServer.image = NSImage.init(named: "NSStatusUnavailable")
        }
    }

    func dialogOKCancel(question: String, text: String) -> Bool {
        let popup: NSAlert = NSAlert()
        popup.messageText = question
        popup.informativeText = text
        popup.alertStyle = NSAlertStyle.warning
        popup.addButton(withTitle: "Yes")
        popup.addButton(withTitle: "No")
        return popup.runModal() == NSAlertFirstButtonReturn
    }
}
