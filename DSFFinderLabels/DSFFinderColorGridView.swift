//
//  CircleColorButton.swift
//  DSFFinderLabelsDemo
//
//  Created by Darren Ford on 8/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

class DSFFinderColorCircleButton: NSButton {

	private func isHighContrast() -> Bool {
		return NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
	}

	public var drawColor: NSColor? {
		didSet {
			self.needsDisplay = true
		}
	}

	public var fillColor: NSColor {
		return self.drawColor ?? NSColor.clear
	}

	public var strokeColor: NSColor {
		if self.isHighContrast() {
			return NSColor.textColor
		}
		if let color = self.drawColor {
			return color.lighter(by: 1.75)
		}
		return NSColor.secondaryLabelColor
	}

	public var highlightedFillColor: NSColor {
		return self.drawColor?.lighter(by: 0.5) ?? NSColor.clear
	}

	public var highlightedStrokeColor: NSColor {
		return self.strokeColor.lighter(by: 0.75)
	}

	public override func drawFocusRingMask() {
		let circlePath = NSBezierPath(ovalIn: self.bounds.insetBy(dx: 1, dy: 1))
		circlePath.fill()
	}

	static var Shadow: NSShadow = {
		let shad = NSShadow()
		shad.shadowBlurRadius = 4
		shad.shadowColor = NSColor.black.withAlphaComponent(0.7)
		shad.shadowOffset = NSSize(width: 1, height: -1)
		return shad
	}()

	public override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		let inset: CGFloat = (self.state == .on) ? 3 : 5

		let rect = NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
		let insetRect = rect.insetBy(dx: inset, dy: inset)
		let circlePath = NSBezierPath(ovalIn: insetRect)

		var fillColor: NSColor?
		var strokeColor: NSColor?

		if self.isHighlighted {
			strokeColor = self.highlightedStrokeColor
			fillColor = self.highlightedFillColor
		} else {
			strokeColor = self.strokeColor
			fillColor = self.fillColor
		}

		if let strokeColor = strokeColor {
			strokeColor.setStroke()
		} else {
			NSColor.textColor.setStroke()
		}

		circlePath.lineWidth = 1
		circlePath.stroke()

		if let fillColor = fillColor {
			fillColor.setFill()
			circlePath.fill()
		}

		// Draw selection
		if self.state == .on
		{
			let circlePath = NSBezierPath(ovalIn: rect.insetBy(dx: 8, dy: 8))

			if self.isHighContrast() {
				NSColor.white.setFill()
				NSColor.black.setStroke()
				circlePath.fill()
				circlePath.lineWidth = 0.5
				circlePath.stroke()
			} else {
				DSFFinderColorCircleButton.Shadow.set()
				NSColor.white.setFill()
				circlePath.fill()
			}
		}
	}
}

private extension NSColor {
	func lighter(by: CGFloat) -> NSColor {
		guard let convertedColor = self.usingColorSpace(.genericRGB) else {
			return self
		}
		var hue: CGFloat = 0
		var saturation: CGFloat = 0
		var brightness: CGFloat = 0
		var alpha: CGFloat = 0
		convertedColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		return NSColor(calibratedHue: hue, saturation: saturation * by, brightness: brightness, alpha: alpha)
	}
}

/// Delegate protocol for users of the DSFFinderColorGridView
public protocol DSFFinderColorGridViewProtocol {
	/// Called when the selection changes
	func selectionChanged(colorIndexes: Set<DSFFinderLabels.ColorIndex>)
}

open class DSFFinderTagsField: NSTokenField {
	public var finderTags: [String] {
		get {
			return self.objectValue as? [String] ?? []
		}
		set {
			self.objectValue = newValue
		}
	}
}

/// A view class for displaying and selecting finder colors
open class DSFFinderColorGridView: NSGridView {
	/// The Finder's colors
	private static let FinderColors = DSFFinderLabels.FinderColors.colors

	private var colorButtons = [DSFFinderColorCircleButton]()

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
		self.colorButtons = self.finderColorButtons()
		self.addRow(with: self.colorButtons)
		self.columnSpacing = 0
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.colorButtons = self.finderColorButtons()
		self.addRow(with: self.colorButtons)
		self.columnSpacing = 0
	}

	/// Unselect all of the colors in the control
	public func reset() {
		self.setSelected(colors: [])
	}

	/// Set the colors to be selected within the control
	///
	/// - Parameter colors: The array of colors to set
	public func setSelected(colors: [DSFFinderLabels.ColorIndex]) {
		self.colorButtons.forEach { $0.state = .off }
		colors.forEach { self.colorButtons[$0.rawValue].state = .on }
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
			let button = DSFFinderColorCircleButton(frame: NSRect(x: 0, y: 0, width: 24, height: 24))
			button.isBordered = false
			button.title = ""
			button.bezelStyle = .shadowlessSquare
			button.setButtonType(.onOff)

			button.grab.width(24, relation: .equal)
			button.grab.height(24, relation: .equal)

			if color.index != .none
			{
				button.drawColor = color.color
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
