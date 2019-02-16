//
//  Document.swift
//  Finder Tagger
//
//  Created by Darren Ford on 9/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

class Document: NSDocument {

	let items = [DSFTaggerViewController(), DSFTaggerViewController(), DSFTaggerViewController()]
	@IBOutlet weak var tableView: NSTableView!

	override init() {
	    super.init()
		// Add your subclass-specific initialization here.
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override var windowNibName: NSNib.Name? {
		// Returns the nib file name of the document
		// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
		return NSNib.Name("Document")
	}

	override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func read(from data: Data, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override read(from:ofType:) instead.
		// If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func awakeFromNib() {
		self.tableView.translatesAutoresizingMaskIntoConstraints = false

		let col0 = self.tableView.tableColumns[0]
		col0.minWidth = self.items[0].view.fittingSize.width + 30

		super.awakeFromNib()
	}

}

extension Document {

}

extension Document: NSTableViewDataSource, NSTableViewDelegate {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.items.count
	}

	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		self.items[row].view.layout()
		return self.items[row].view.fittingSize.height + 30
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		return self.items[row].view
	}
}
