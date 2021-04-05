//
//  DSFFinderColorGridView.swift
//  DSFFinderLabelsDemo
//
//  Created by Darren Ford on 8/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

/// Delegate protocol for users of the DSFFinderColorGridView
public protocol DSFFinderColorGridViewProtocol {
	/// Called when the selection changes
	func selectionChanged(colorIndexes: Set<DSFFinderLabels.ColorIndex>)
}

/// A view class for displaying and selecting finder colors
@available(macOS 10.11, *)
@IBDesignable public class DSFFinderColorGridView: NSView {

	/// Delegate for notifying back when selections change
	public var selectionDelegate: DSFFinderColorGridViewProtocol?

	/// The colors currently selected in the control
	public var selectedColors: [DSFFinderLabels.ColorIndex] {
		return self.colorButtons
			.filter({ $0.state == .on })
			.compactMap { DSFFinderLabels.ColorIndex(rawValue: $0.tag) }
	}

	public override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	override public func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		//self.setup()
		self.reset()
		//self.needsLayout = true
	}

	public override var intrinsicContentSize: NSSize {
		return self.stack.fittingSize
	}

	/// Unselect all of the colors in the control
	public func reset() {
		self.setSelected(colors: [])
	}

	/// Set the colors to be selected within the control
	///
	/// - Parameter colors: The array of colors to set
	public func setSelected(colors: Set<DSFFinderLabels.ColorIndex>) {
		self.colorButtons.forEach {
			if let which = DSFFinderLabels.ColorIndex(rawValue: $0.tag) {
				let isSet = colors.contains(which)
				$0.state = isSet ? .on : .off
			}
		}
	}

	// MARK: Private

	private var colorButtons = [DSFFinderColorCircleButton]()
	private let buttonSize: CGFloat = 24
	private lazy var stack: NSStackView = {
		let item = NSStackView()
		item.translatesAutoresizingMaskIntoConstraints = false
		item.orientation = .horizontal
		item.spacing = 0
		return item
	}()

	/// The Finder's colors
	private lazy var displayColors: [DSFFinderLabels.ColorDefinitions.Definition] = {
		DSFFinderLabels.FinderColors.colorsRainbowOrdered
			.reversed()                      // Try to match Finder's ordering
			.filter { $0.index != .none }    // Remove the 'none'
	}()
}

@available(macOS 10.11, *)
private extension DSFFinderColorGridView {

	@objc private func selectedButton(_ sender: DSFFinderColorCircleButton) {
		if sender.tag == DSFFinderLabels.ColorIndex.none.rawValue {
			self.reset()
		}

		// Tell our delegate when the change occurs
		self.selectionDelegate?.selectionChanged(colorIndexes: Set(self.selectedColors))
	}


	func setup() {

		self.translatesAutoresizingMaskIntoConstraints = false

		self.addSubview(self.stack)
		self.stack.frame = self.bounds

		self.addConstraints([
			NSLayoutConstraint(item: self.stack, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.stack, attribute: .right, relatedBy: .lessThanOrEqual, toItem: self, attribute: .right, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.stack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.stack, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
		])

		self.colorButtons = self.finderColorButtons()
		self.colorButtons.forEach { self.stack.addArrangedSubview($0) }

		self.needsLayout = true
	}

	func finderColorButtons() -> [DSFFinderColorCircleButton] {

		let result: [DSFFinderColorCircleButton] = self.displayColors.map { color in

			let button = DSFFinderColorCircleButton(frame: NSRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
			button.translatesAutoresizingMaskIntoConstraints = false
			button.isBordered = false
			button.title = ""
			button.bezelStyle = .shadowlessSquare
			button.setButtonType(.toggle)

			button.addConstraints([
				NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonSize),
				NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonSize)
			])

			button.drawColor = color.color
			button.tag = color.index.rawValue
			button.setAccessibilityLabel(color.label)
			button.toolTip = color.label

			button.target = self
			button.action = #selector(DSFFinderColorGridView.selectedButton(_:))

			button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
			button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

			return button
		}

		return result
	}
}
