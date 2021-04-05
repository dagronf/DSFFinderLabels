//
//  DSFFinderLabels+Colors.swift
//  DSFFinderLabels
//
//  Created by Darren Ford on 6/4/21.
//  Copyright © 2021 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2021 Darren Ford
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#if canImport(AppKit)

import AppKit

extension DSFFinderLabels {

	/// Standard Finder color indexes
	@objc(DSFFinderLabelsColorIndex) public enum ColorIndex: Int, Codable {
		case none = 0
		case grey = 1
		case green = 2
		case purple = 3
		case blue = 4
		case yellow = 5
		case red = 6
		case orange = 7
	}

	/// An object that contains all of the Finder color definitions
	@objc(DSFFinderLabelColorDefinitions) open class ColorDefinitions: NSObject {
		/// Representation of a finder 'color' label
		@objc(DSFFinderLabelColorDefinition) open class Definition: NSObject {
			/// The Finder index for the specific color
			public let index: ColorIndex
			/// The Finder label (title) for the color
			public let label: String
			/// The Finder color specified for the label.
			/// This is a custom color defined to mostly match what is show in the finder
			public let color: NSColor
			/// The color as reported by the finder.
			/// This color is quite muted compared with what is shown in the Finder!
			///
			/// NOTE: Big Sur appears to have fixed the mutedness. Leaving for backwards compatibility
			public let finderColor: NSColor

			fileprivate init(index: ColorIndex, label: String, color: NSColor, finderColor _: NSColor) {
				self.index = index
				self.label = label
				self.color = color
				self.finderColor = color
			}
		}

		/// Returns a custom color that represents the color index.
		///
		/// This is used because the colors that are returned by NSWorkspace are very muted compared with
		/// what is shown in the Finder's UI.
		///
		/// NOTE: This seems to have been fixed in Big Sur - the colors returned from the Finder match the
		/// system color definitions
		///
		/// - Parameter colorIndex: The color index
		/// - Returns: The custom color for the index
		fileprivate static func CustomColorForIndex(_ colorIndex: ColorIndex) -> NSColor {
			switch colorIndex {
			case .none:
				return NSColor.clear
			case .grey:
				return NSColor.systemGray
			case .green:
				return NSColor.systemGreen
			case .purple:
				return NSColor.systemPurple
			case .blue:
				return NSColor.systemBlue
			case .yellow:
				return NSColor.systemYellow
			case .red:
				return NSColor.systemRed
			case .orange:
				return NSColor.systemOrange
			}
		}

		/// The finder color definitions
		public let colors: [ColorDefinitions.Definition]

		/// Returns the colors in rainbow order
		public var colorsRainbowOrdered: [ColorDefinitions.Definition] {
			return [
				self.color(for: .none)!,
				self.color(for: .grey)!,
				self.color(for: .purple)!,
				self.color(for: .blue)!,
				self.color(for: .green)!,
				self.color(for: .yellow)!,
				self.color(for: .orange)!,
				self.color(for: .red)!,
			]
		}

		fileprivate init(colors: [ColorDefinitions.Definition]) {
			self.colors = colors
		}

		/// Returns the color definition for the specified color index
		@objc public func color(for index: ColorIndex) -> ColorDefinitions.Definition? {
			return self.colors.first(where: { $0.index == index })
		}

		/// Returns the color definition for the specified color title
		@objc public func color(labelled label: String) -> ColorDefinitions.Definition? {
			return self.colors.first(where: { $0.label == label })
		}

		/// Returns the (localized) labels for all of the known finder colors
		@objc var allColorLabels: Set<String> {
			return Set(self.colors.map { $0.label })
		}
	}
}

extension DSFFinderLabels {
	/// Returns an array of standard finder color definitions
	static func GetFinderColors() -> ColorDefinitions {
		var clrs: [ColorDefinitions.Definition] = []
		let vals = zip(NSWorkspace.shared.fileLabels, NSWorkspace.shared.fileLabelColors)
			.map { (label: $0, color: $1) }

		for val in vals.enumerated() {
			if let index = ColorIndex(rawValue: val.0) {
				let customColor = ColorDefinitions.CustomColorForIndex(index)
				clrs.append(ColorDefinitions.Definition(index: index, label: val.1.label, color: customColor, finderColor: val.1.color))
			}
		}
		return ColorDefinitions(colors: clrs)
	}
}

#endif
