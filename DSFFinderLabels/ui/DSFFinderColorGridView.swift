//
//  CircleColorButton.swift
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

@objc open class DSFFinderColorGridView: NSView {
	/// The Finder's colors
	private static let FinderColors = DSFFinderLabels.FinderColors.colors

	private var colorButtons = [DSFFinderColorCircleButton]()

	private let grid = NSGridView()
	private let buttonSize: CGFloat = 24

	/// Delegate for notifying back when selections change
	public var selectionDelegate: DSFFinderColorGridViewProtocol?

	/// The colors currently selected in the control
	public var selectedColors: [DSFFinderLabels.ColorIndex] {
		return self.colorButtons
			.filter({ $0.state == .on })
			.compactMap { DSFFinderLabels.ColorIndex(rawValue: $0.tag) }
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	private func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.colorButtons = self.finderColorButtons()
		self.grid.translatesAutoresizingMaskIntoConstraints = false
		self.grid.addRow(with: self.colorButtons)
		self.grid.columnSpacing = 0
		self.grid.setContentCompressionResistancePriority(.required, for: .horizontal)
		self.grid.setContentCompressionResistancePriority(.required, for: .vertical)
		self.grid.setContentHuggingPriority(.required, for: .horizontal)
		self.grid.setContentHuggingPriority(.required, for: .vertical)

		self.addSubview(self.grid)
		self.addConstraints([
			NSLayoutConstraint(item: self.grid, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.grid, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.grid, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.grid, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),

			NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.colorButtons[0].frame.height)
		])

		self.needsLayout = true
	}

	open override func prepareForInterfaceBuilder() {
		self.setup()
		self.reset()
		self.needsLayout = true

		//super.prepareForInterfaceBuilder()
	}

	/// Unselect all of the colors in the control
	public func reset() {
		self.setSelected(colors: [])
	}

	/// Set the colors to be selected within the control
	///
	/// - Parameter colors: The array of colors to set
	public func setSelected(colors: [DSFFinderLabels.ColorIndex]) {
		self.colorButtons.forEach {
			if let which = DSFFinderLabels.ColorIndex(rawValue: $0.tag) {
				let isSet = colors.contains(which)
				$0.state = isSet ? .on : .off
			}
		}
	}

	@objc private func selectedButton(_ sender: DSFFinderColorCircleButton) {
		if sender.tag == DSFFinderLabels.ColorIndex.none.rawValue {
			self.reset()
		}

		// Tell our delegate when the change occurs
		self.selectionDelegate?.selectionChanged(colorIndexes: Set(self.selectedColors))
	}

	private func finderColorButtons() -> [DSFFinderColorCircleButton] {
		var arr = [DSFFinderColorCircleButton]()
		for color in DSFFinderLabels.FinderColors.colorsRainbowOrdered {
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

			if color.index != .none {
				button.drawColor = color.color
			}
			else {
				button.image = NSImage.init(named: NSImage.removeTemplateName)
			}
			button.tag = color.index.rawValue
			button.setAccessibilityLabel(color.label)
			button.toolTip = color.label

			button.target = self
			button.action = #selector(DSFFinderColorGridView.selectedButton(_:))

			arr.append(button)
		}

		return arr
	}
}
