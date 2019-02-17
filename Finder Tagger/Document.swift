//
//  Document.swift
//  Finder Tagger
//
//  Created by Darren Ford on 9/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

import DSFFinderLabels

class FinderTagger: NSObject, Codable {
	var name = "<untitled>"
	let tags: DSFFinderLabels
	var child = [FinderTagger]()

	override init() {
		self.tags = DSFFinderLabels()
		super.init()
	}
}

@objc class FilePathCellView: NSTableCellView {
	@IBOutlet weak var path: NSPathControl!
}

class Document: NSDocument {


	@IBOutlet weak var outlineView: NSOutlineView!
	@IBOutlet weak var searchResultsTableView: NSTableView!
	
	@IBOutlet weak var selectedItemView: DSFDragFilesView!
	@IBOutlet weak var selectedTitleField: NSTextField!
	@IBOutlet weak var selectedColorView: DSFFinderColorGridView!
	@IBOutlet weak var selectedTagsView: DSFFinderTagsField!

	private var items: [FinderTagger] = []

	private var activeSearch: DSFFinderLabels.Search? = nil
	private var lastSearchResult = [String]() {
		didSet {
			self.searchResultsTableView.reloadData()
		}
	}

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

		let encoder = JSONEncoder()
		return try encoder.encode(self.items)

		//throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func read(from data: Data, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override read(from:ofType:) instead.
		// If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.

		self.items = try JSONDecoder().decode([FinderTagger].self, from: data)

	//	throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		let at = try? DSFFinderLabels.allTags()

		self.selectedColorView.selectionDelegate = self
		self.selectedTitleField.delegate = self
		self.selectedTagsView.delegate = self
		self.selectedItemView.dropDelegate = self
	}

}

extension Document: NSOutlineViewDelegate {

	private func selectedItem() -> FinderTagger? {
		return self.outlineView.item(atRow: self.outlineView.selectedRow) as? FinderTagger
	}

	func outlineViewSelectionDidChange(_ notification: Notification) {
		if let item = self.selectedItem() {
			self.updateWithSelection(item)
		}
		else {
			self.selectedColorView.reset()
			self.selectedTitleField.stringValue = ""
			self.selectedTagsView.finderTags.removeAll()
		}
	}

}

extension Document: DSFDragFilesViewProtocol {
	func droppedFiles(urls: [URL]) {
		if let tagger = self.selectedItem() {
			try? tagger.tags.update(urls: urls)
			self.searchWithCurrent(tagger)
		}
	}
}

extension Document: NSTableViewDataSource, NSTableViewDelegate {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.lastSearchResult.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard tableView == self.searchResultsTableView else {
			return nil
		}

		if let c = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("searchResultTableViewCell"), owner: self) as? FilePathCellView,
			let pth = c.viewWithTag(2002) as? NSPathControl {
			pth.url = URL(fileURLWithPath: self.lastSearchResult[row])
			return c
		}
		return nil
	}
}

extension Document: DSFFinderColorGridViewProtocol, NSTextFieldDelegate, NSTokenFieldDelegate {

	func selectionChanged(colorIndexes: Set<DSFFinderLabels.ColorIndex>) {
		if let item = self.selectedItem() {
			item.tags.colors = Set(self.selectedColorView.selectedColors)
			self.searchWithCurrent(item)
		}
		else {
			self.selectedColorView.reset()
		}
		self.updateChangeCount(.changeDone)
	}

	func searchWithCurrent(_ item: FinderTagger) {
		self.activeSearch?.stop()

		self.lastSearchResult.removeAll()
		self.activeSearch = item.tags.findAllMatching { [weak self] (results) in
			self?.lastSearchResult = results.map { $0.path }
		}
	}

	func controlTextDidEndEditing(_ obj: Notification) {
		if let selected = self.selectedItem() {
			self.updateChangeCount(.changeDone)
			if obj.object as? NSTextField == self.selectedTitleField {
				selected.name = self.selectedTitleField.stringValue
			}
			else if obj.object as? DSFFinderTagsField == self.selectedTagsView {
				selected.tags.setTags(tags: Set(self.selectedTagsView.finderTags))
			}
			self.outlineView.reloadItem(selected)
			self.searchWithCurrent(selected)
		}
	}

	func updateWithSelection(_ item: FinderTagger) {
		self.selectedTitleField.stringValue = item.name
		self.selectedColorView.setSelected(colors: Array(item.tags.colors))
		self.selectedTagsView.finderTags = Array(item.tags.tags)
		self.searchWithCurrent(item)
	}
}

extension Document: NSOutlineViewDataSource {

	@IBAction func addItem(_ sender: Any) {
		if outlineView.selectedRow == -1 {
			items.append(FinderTagger())
			self.outlineView.reloadData()
		}
		else {
			let r = outlineView.selectedRow

			if let e = outlineView.item(atRow: r) as? FinderTagger {
				let t = FinderTagger()
				e.child.append(t)
				outlineView.reloadItem(e, reloadChildren: true)

				outlineView.expandItem(e)

				let rr = outlineView.row(forItem: t)
				self.outlineView.selectRowIndexes(IndexSet(integer: rr), byExtendingSelection: false)
			}
		}
		self.updateChangeCount(.changeDone)
	}

	@IBAction func deleteSelectedItem(_ sender: Any) {
		let selected = outlineView.selectedRow
		guard selected >= 0,
			let selectedItem = outlineView.item(atRow: selected) as? FinderTagger else {
			return
		}

		if let parent = outlineView.parent(forItem: selectedItem) as? FinderTagger {
			parent.child.removeAll { (item) -> Bool in
				return item === selectedItem
			}
			outlineView.reloadItem(parent, reloadChildren: true)
		}
		else {
			self.items.removeAll { (item) -> Bool in
				return selectedItem === item
			}
			outlineView.reloadData()
		}
		self.updateChangeCount(.changeDone)
	}

	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let item = item as? FinderTagger {
			return item.child.count
		}
		return self.items.count
	}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let item = item as? FinderTagger {
			return item.child.count > 0
		}
		return false
	}

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let item = item as? FinderTagger {
			return item.child[index]
		}
		else {
			return self.items[index]
		}
	}

	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		guard let item = item as? FinderTagger else {
			return nil
		}

		let v = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outlineViewCell"), owner: self) as! NSTableCellView
		v.textField?.stringValue = item.name
		return v
	}
}
