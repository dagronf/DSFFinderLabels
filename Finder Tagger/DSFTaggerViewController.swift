//
//  DSFTaggerViewController.swift
//  Finder Tagger
//
//  Created by Darren Ford on 9/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

import DSFFinderLabels

protocol DSFDragFilesViewProtocol {
	func droppedFiles(urls: [URL])
}

class DSFDragFilesView: NSView {

	var dropDelegate: DSFDragFilesViewProtocol?

	static let fileURLs = NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		self.setup()
	}

	private func setup() {
		self.registerForDraggedTypes([DSFDragFilesView.fileURLs])
	}

	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		return .copy
	}

	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {

		if let files = sender.draggingPasteboard.propertyList(forType: DSFDragFilesView.fileURLs) as? [String] {
			let URLs = files.map { URL(fileURLWithPath: $0) }
			self.dropDelegate?.droppedFiles(urls: URLs)
			return true
		}
		return false
	}
}


class DSFTaggerViewController:
	NSViewController,
	DSFDragFilesViewProtocol,
	DSFFinderColorGridViewProtocol,
	NSTokenFieldDelegate {

	let tags = DSFFinderLabels()

	let taggerLabel = NSTextField()
	let colorSelector = DSFFinderColorGridView()
	let tagSelector = DSFFinderTagsField()

	var activeSearch: DSFFinderLabels.Search?

	func droppedFiles(urls: [URL]) {

		self.tags.colors = Set(colorSelector.selectedColors)
		self.tags.tags = Set(tagSelector.finderTags)

		try? self.tags.update(urls: urls)
	}

	override func loadView()
	{
		let primaryView = DSFDragFilesView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))
		primaryView.dropDelegate = self
		self.view = primaryView
		self.view.translatesAutoresizingMaskIntoConstraints = false

		// Setup the color selector
		colorSelector.setContentCompressionResistancePriority(.required, for: .vertical)
		colorSelector.setContentHuggingPriority(.required, for: .vertical)
		colorSelector.setContentCompressionResistancePriority(.required, for: .horizontal)
		colorSelector.setContentHuggingPriority(.required, for: .horizontal)
		colorSelector.translatesAutoresizingMaskIntoConstraints = false
		colorSelector.selectionDelegate = self

		// Setup the tag selector
		tagSelector.translatesAutoresizingMaskIntoConstraints = false
		tagSelector.delegate = self

		// Setup the label
		taggerLabel.isEditable = true
		taggerLabel.translatesAutoresizingMaskIntoConstraints = false
		taggerLabel.setContentHuggingPriority(.defaultLow, for: .vertical)

		self.view.addSubview(taggerLabel)
		self.view.addSubview(colorSelector)
		self.view.addSubview(tagSelector)

		let vc = self.view.grab
		vc.vStack([(.equal, 10, taggerLabel),
				   (.equal, 10, colorSelector),
				   (.equal, 10, tagSelector)],
				  .greaterThanOrEqual, 10)

		// Fix the height of the tag selector
		tagSelector.grab.height(50, relation: .equal)

		vc.equal(.leading, taggerLabel, self.view, constant: 10)
		vc.equal(.trailing, taggerLabel, self.view, constant: -10)

		vc.equal(.leading, tagSelector, taggerLabel)
		vc.equal(.trailing, tagSelector, taggerLabel)

		vc.equal(.leading, colorSelector, self.view, constant: 10)
		let c = vc.equal(.trailing, colorSelector, self.view, constant: -10)
		c?.priority = .defaultLow

		self.view.needsLayout = true
	}

	func controlTextDidEndEditing(_ obj: Notification) {
		self.tags.tags = Set(self.tagSelector.finderTags)
	}

	var searchCallback: ((Set<URL>) -> Void)?

	func search() {

		self.activeSearch?.stop()
		self.activeSearch = nil

		self.activeSearch = self.tags.findAllMatching { (urls) in
			print(urls)
		}
	}

	func selectionChanged(colorIndexes: Set<DSFFinderLabels.ColorIndex>) {
		self.tags.colors = colorIndexes
		self.search()
	}
}
