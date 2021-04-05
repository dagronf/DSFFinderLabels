//
//  DSFFinderLabels.swift
//  DSFFinderLabels
//
//  Created by Darren Ford on 8/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2019 Darren Ford
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

import Cocoa

enum DSFFinderLabelsError: Error {
	case sandboxed
}

@objc open class DSFFinderLabels: NSObject, Codable {
	// MARK: Definitions

	enum CodingKeys: String, CodingKey {
		case tags
		case colors
	}

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

	/// Returns an array of standard finder color definitions
	@objc public static let FinderColors: ColorDefinitions = {
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
	}()

	// MARK: Settable members

	/// The currently defined tags
	public var tags: Set<String>
	/// The currently defined color indexes
	public var colors: Set<DSFFinderLabels.ColorIndex>

	public var activeSearch: DSFFinderLabels.Search?

	// MARK: Initializers

	public init(colors: [ColorIndex] = [], tags: [String] = []) {
		self.colors = Set(colors)
		self.tags = Set(tags)
		super.init()
	}

	public init(fileURL: URL) {
		self.tags = Set<String>()
		self.colors = Set<DSFFinderLabels.ColorIndex>()
		super.init()
		self.reset(with: fileURL)
	}
}

// MARK: Swift helpers for set and unset

public extension DSFFinderLabels {
	/// Add the specified color(s) to the object
	func set(colors: [ColorIndex]) {
		//self.colors.formUnion(colors)
		colors.forEach { self.colors.insert($0) }
	}

	/// Remove the specified color(s) to the object
	func unset(colors: [ColorIndex]) {
		colors.forEach { self.colors.remove($0) }
	}

	/// Add the specified tag string(s) to the object
	func set(tags: [String]) {
		tags.forEach { self.tags.insert($0) }
	}

	/// Remove the specified tag string(s) from the object
	func unset(tags: [String]) {
		tags.forEach { self.tags.remove($0) }
	}
}

public extension DSFFinderLabels {
	/// Add the specified color to the object
	static func += (lhs: DSFFinderLabels, rhs: ColorIndex) {
		lhs.set(colors: [rhs])
	}

	/// Remove the specified color to the object
	static func -= (lhs: DSFFinderLabels, rhs: ColorIndex) {
		lhs.unset(colors: [rhs])
	}

	/// Add the specified color(s) to the object
	static func += (lhs: DSFFinderLabels, rhs: [ColorIndex]) {
		lhs.set(colors: rhs)
	}

	/// Remove the specified color(s) to the object
	static func -= (lhs: DSFFinderLabels, rhs: [ColorIndex]) {
		lhs.unset(colors: rhs)
	}
}

public extension DSFFinderLabels {
	/// Add the specified tag string to the object
	static func += (lhs: DSFFinderLabels, rhs: String) {
		lhs.set(tags: [rhs])
	}

	/// Add the specified tag string(s) to the object
	static func += (lhs: DSFFinderLabels, rhs: [String]) {
		lhs.set(tags: rhs)
	}

	/// Remove the specified tag string from the object
	static func -= (lhs: DSFFinderLabels, rhs: String) {
		lhs.unset(tags: [rhs])
	}

	/// Remove the specified tag string(s) from the object
	static func -= (lhs: DSFFinderLabels, rhs: [String]) {
		lhs.unset(tags: rhs)
	}
}

// MARK: Reset and load

@objc extension DSFFinderLabels {
	/// Clear all of the tags and colors
	public func clear() {
		self.colors.removeAll()
		self.tags.removeAll()
	}

	/// Replace the current values with the labels for the specified URL
	///
	/// - Parameter fileURL: The URL to load the new values from
	public func reset(with fileURL: URL) {
		// Clear out all the stored values
		self.clear()

		guard let r = try? fileURL.resourceValues(forKeys: [.tagNamesKey]),
			let tags = r.tagNames else {
			return
		}

		for item in tags {
			if let color = DSFFinderLabels.FinderColors.colors.first(where: { $0.label == item }) {
				self.colors.insert(color.index)
			}
			else {
				self.tags.insert(item)
			}
		}
	}

	/// Is the specified color index set?
	///
	/// - Parameter colorIndex: the color index to check
	/// - Returns: true if the color exists, false otherwise
	public func hasColorIndex(_ colorIndex: ColorIndex) -> Bool {
		return self.colors.firstIndex(of: colorIndex) == nil ? false : true
	}

	/// Is the specified tag set?
	///
	/// - Parameter tag: The tag to check
	/// - Returns: true if the tag exists, false otherwise
	public func hasTag(_ tag: String) -> Bool {
		return self.tags.firstIndex(of: tag) == nil ? false : true
	}
}

// MARK: Update

extension DSFFinderLabels {
	/// Update the URL with the current label values
	@objc public func update(url: URL) throws {
		var tags = self.tags

		// Add in the user's colors as tags
		let colorTags = self.colors.compactMap { DSFFinderLabels.FinderColors.color(for: $0)?.label }
		tags.formUnion(colorTags)

		try (url as NSURL).setResourceValue(Array(tags), forKey: .tagNamesKey)
	}

	/// Update the given URLs with the current label values
	@objc public func update(urls: [URL]) throws {
		try urls.forEach { try self.update(url: $0) }
	}
}

extension DSFFinderLabels {
	private static func throwIfSandboxed() throws {
		let bundleURL = Bundle.main.bundleURL
		var staticCode: SecStaticCode?
		let kSecCSDefaultFlags: SecCSFlags = SecCSFlags(rawValue: SecCSFlags.RawValue(0))

		if SecStaticCodeCreateWithPath(bundleURL as CFURL, kSecCSDefaultFlags, &staticCode) == errSecSuccess {
			if SecStaticCodeCheckValidityWithErrors(staticCode!, SecCSFlags(rawValue: kSecCSBasicValidateOnly), nil, nil) == errSecSuccess {
				let appSandbox = "entitlement[\"com.apple.security.app-sandbox\"] exists"
				var sandboxRequirement: SecRequirement?

				if SecRequirementCreateWithString(appSandbox as CFString, kSecCSDefaultFlags, &sandboxRequirement) == errSecSuccess {
					let codeCheckResult: OSStatus = SecStaticCodeCheckValidityWithErrors(staticCode!, SecCSFlags(rawValue: kSecCSBasicValidateOnly), sandboxRequirement, nil)
					if codeCheckResult == errSecSuccess {
						throw DSFFinderLabelsError.sandboxed
					}
				}
			}
		}
		return
	}

	@available(OSX 10.11, *)
	private static func allTagLabels() throws -> [(String, Int)] {
		/// Cannot be called from a sandboxed environment
		try self.throwIfSandboxed()

		let libPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
		guard libPath.count > 0 else {
			return []
		}

		let ll = libPath[0]
		let url = URL(fileURLWithPath: "SyncedPreferences/com.apple.finder.plist",
		              relativeTo: URL(fileURLWithPath: ll))

		let keyPath = "values.FinderTagDict.value.FinderTags"
		if let d = try? Data(contentsOf: url) {
			if let plist = try? PropertyListSerialization.propertyList(from: d, options: [], format: nil),
				let pdict = plist as? NSDictionary,
				let ftags = pdict.value(forKeyPath: keyPath) as? [[AnyHashable: Any]] {
				return ftags.compactMap {
					if let name = $0["n"] as? String {
						let index = $0["l"] as? Int ?? -1
						return (name, index)
					}
					return nil
				}
			}
		}
		return []
	}

	@available(OSX 10.11, *)
	public static func allTags() throws -> [(String, DSFFinderLabels.ColorIndex)] {
		let vals = try self.allTagLabels()

		let colorLabels = DSFFinderLabels.FinderColors.allColorLabels

		var tags = [(String, DSFFinderLabels.ColorIndex)]()
		for tag in vals {
			if !colorLabels.contains(tag.0) {
				let ci = ColorIndex(rawValue: tag.1) ?? .none
				tags.append((tag.0, ci))
			}
		}

		// Map the tags and colors to the output
		return tags
	}
}

// MARK: - Color Definition Helpers

extension DSFFinderLabels {
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

// MARK: - URL Extension

public extension URL {
	/// Returns the finder labels for the current URL
	func finderLabels() -> DSFFinderLabels {
		return DSFFinderLabels(fileURL: self)
	}

	/// Set the labels defined by 'finderLabels' to the URL
	func setFinderLabels(_ finderLabels: DSFFinderLabels) throws {
		try finderLabels.update(url: self)
	}

	func setFinderLabels(colors: [DSFFinderLabels.ColorIndex] = [], tags: [String] = []) throws {
		let labels = DSFFinderLabels(colors: colors, tags: tags)
		try labels.update(url: self)
	}
}
