//
//  ViewController.swift
//  macWebretail
//
//  Created by Gerardo Grisolini on 19/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet weak var progressView: NSProgressIndicator!
	@IBOutlet weak var collectionView: NSCollectionView!
	
	var items = [(key:String, value:[Movement])]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureCollectionView()
	}
	
	override func viewDidAppear() {
		reloadData()
	}
	
	public func reloadData() {
		collectionView.alphaValue = 0.2
		progressView.isHidden = false
		progressView.startAnimation(self)
		
		DispatchQueue.global(qos: .background).async {
			
			Synchronizer.shared.synchronize()
			
			self.items = Synchronizer.shared.movements
				.groupBy { $0.date.formatDateShort() }
				.sorted { $0.key > $1.key }

			DispatchQueue.main.async {
				self.collectionView.alphaValue = 1.0
				self.collectionView.reloadData()
				self.progressView.stopAnimation(self)
				self.progressView.isHidden = true
			}
		}
	}
	
	fileprivate func configureCollectionView() {
		let flowLayout = NSCollectionViewFlowLayout()
		flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
		flowLayout.sectionInset = EdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0)
		flowLayout.minimumInteritemSpacing = 20.0
		flowLayout.minimumLineSpacing = 20.0
		flowLayout.sectionHeadersPinToVisibleBounds = true
		collectionView.collectionViewLayout = flowLayout
		view.wantsLayer = true
		collectionView.layer?.backgroundColor = NSColor.white.cgColor
		collectionView.register(CollectionViewItem.self, forItemWithIdentifier: "CollectionViewItem")
	}
}

extension ViewController : NSCollectionViewDataSource {
	
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return items.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return items[section].value.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
		
		let view = collectionView.makeSupplementaryView(ofKind: NSCollectionElementKindSectionHeader, withIdentifier: "HeaderView", for: indexPath) as! HeaderView
		
		view.headerText.stringValue = self.items[indexPath.section].key
		view.headerCount.stringValue = "\(self.items[indexPath.section].value.count) documents"
		
		return view
	}
	
	func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		
		let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath)
		guard let collectionViewItem = item as? CollectionViewItem else {
			return item
		}

		let movement = items[indexPath.section].value[indexPath.item]

		collectionViewItem.id = movement.id
		collectionViewItem.numberText.stringValue = movement.number.description
		collectionViewItem.amountText.stringValue = movement.amount.formatCurrency()
		collectionViewItem.causalText.stringValue = movement.causal
		collectionViewItem.descriptionText.stringValue = movement.description
		collectionViewItem.deviceText.stringValue = movement.device

		return collectionViewItem
	}
}

extension ViewController : NSCollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
		return NSSize(width: 1000, height: 40)
	}
}

