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

	let dropLayer = CAShapeLayer()

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

		self.wantsLayer = true
	}

	private func showDropAnimation() {

		let inset = self.bounds.insetBy(dx: 5, dy: 5)

		self.dropLayer.frame = inset

		self.dropLayer.path = CGPath(roundedRect: self.dropLayer.bounds,
									 cornerWidth: 4.0, cornerHeight: 4.0, transform: nil)

		self.dropLayer.strokeColor = NSColor.controlAccentColor.cgColor
		self.dropLayer.lineWidth = 3.0
		self.dropLayer.fillColor = NSColor.clear.cgColor

		self.dropLayer.lineDashPattern = [5]

		let lineDashPhaseAnimation = CABasicAnimation(keyPath: "lineDashPhase")
		lineDashPhaseAnimation.byValue = 10.0
		lineDashPhaseAnimation.duration = 0.75
		lineDashPhaseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
		lineDashPhaseAnimation.repeatCount = .greatestFiniteMagnitude

		self.dropLayer.add(lineDashPhaseAnimation, forKey: "lineDashPhaseAnimation")

		self.layer?.addSublayer(self.dropLayer)
	}

	private func hideDropAnimation() {
		self.dropLayer.removeAllAnimations()
		self.dropLayer.removeFromSuperlayer()
	}

	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		self.showDropAnimation()
		return .copy
	}

	override func draggingExited(_ sender: NSDraggingInfo?) {
		self.hideDropAnimation()
	}

	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		self.hideDropAnimation()
		if let files = sender.draggingPasteboard.propertyList(forType: DSFDragFilesView.fileURLs) as? [String] {
			let URLs = files.map { URL(fileURLWithPath: $0) }
			self.dropDelegate?.droppedFiles(urls: URLs)
			return true
		}
		return false
	}
}

//
//class DSFTaggerViewController:
//	NSViewController,
//	DSFDragFilesViewProtocol,
//	DSFFinderColorGridViewProtocol,
//	NSTokenFieldDelegate {
//
//	let tags = DSFFinderLabels()
//
//	let vstack = NSStackView()
//	let taggerLabel = NSTextField()
//	let colorSelector = DSFFinderColorGridView()
//	let tagSelector = DSFFinderTagsField()
//
//	var activeSearch: DSFFinderLabels.Search?
//
//	func droppedFiles(urls: [URL]) {
//
//		self.tags.colors = Set(colorSelector.selectedColors)
//		self.tags.tags = Set(tagSelector.finderTags)
//
//		try? self.tags.update(urls: urls)
//	}
//
//	override func loadView()
//	{
//		let primaryView = DSFDragFilesView(frame: NSRect(x: 0, y: 0, width: 10, height: 10))
//		primaryView.translatesAutoresizingMaskIntoConstraints = false
//		primaryView.dropDelegate = self
//		self.view = primaryView
//
//		// Setup the color selector
//		colorSelector.setContentCompressionResistancePriority(.required, for: .vertical)
//		colorSelector.setContentHuggingPriority(.required, for: .vertical)
//		colorSelector.setContentCompressionResistancePriority(.required, for: .horizontal)
//		colorSelector.setContentHuggingPriority(.required, for: .horizontal)
//		colorSelector.translatesAutoresizingMaskIntoConstraints = false
//		colorSelector.selectionDelegate = self
//
//		// Setup the tag selector
//		tagSelector.translatesAutoresizingMaskIntoConstraints = false
//		tagSelector.delegate = self
//		tagSelector.grab.height(50, relation: .equal)
//
//		// Setup the label
//		taggerLabel.isEditable = true
//		taggerLabel.translatesAutoresizingMaskIntoConstraints = false
//		taggerLabel.setContentHuggingPriority(.required, for: .vertical)
//
//		// Configure the stack
//		vstack.orientation = .vertical
//		vstack.translatesAutoresizingMaskIntoConstraints = false
//		vstack.edgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//		vstack.alignment = .centerX
//
//		vstack.addArrangedSubview(taggerLabel)
//		vstack.addArrangedSubview(colorSelector)
//		vstack.addArrangedSubview(tagSelector)
//
//		vstack.setContentCompressionResistancePriority(.required, for: .horizontal)
//		vstack.setHuggingPriority(.required, for: .horizontal)
//		vstack.setContentCompressionResistancePriority(.required, for: .vertical)
//		vstack.setHuggingPriority(.required, for: .vertical)
//
//		primaryView.addSubview(vstack)
//
//		let vc = self.view.grab
//		vc.top(view: vstack, related: .equal)
//		vc.bottom(view: vstack, related: .equal)
//		vc.centerX(vstack)
//		vc.left(view: vstack, related: .greaterThanOrEqual, constant: 0.0)
//
//		primaryView.needsLayout = true
//	}
//
//	func controlTextDidEndEditing(_ obj: Notification) {
//		self.tags.tags = Set(self.tagSelector.finderTags)
//	}
//
//	var searchCallback: ((Set<URL>) -> Void)?
//
//	func search() {
//
//		self.activeSearch?.stop()
//		self.activeSearch = nil
//
//		self.activeSearch = self.tags.findAllMatching { (urls) in
//			print(urls)
//		}
//	}
//
//	func selectionChanged(colorIndexes: Set<DSFFinderLabels.ColorIndex>) {
//		self.tags.colors = colorIndexes
//		self.search()
//	}
//}
