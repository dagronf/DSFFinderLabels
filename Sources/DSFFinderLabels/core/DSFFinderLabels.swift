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

	enum CodingKeys: String, CodingKey {
		case tags
		case colors
	}

	/// The array of standard finder colors
	@objc public static let FinderColors: ColorDefinitions = GetFinderColors()

	/// The currently defined tags
	public var tags: Set<String>
	/// The currently defined color indexes
	public var colors: Set<DSFFinderLabels.ColorIndex>

	/// Returns all the finder labels (tags and colors) including the localized color names
	public var allLabels: Set<String> {
		let colorTags = self.colors.compactMap { DSFFinderLabels.FinderColors.color(for: $0)!.label }
		return self.tags.union(colorTags)
	}

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

// MARK: - Clear

@objc extension DSFFinderLabels {
	/// Remove all tags and colors
	@discardableResult public func removeAll() -> DSFFinderLabels {
		self.colors.removeAll()
		self.tags.removeAll()
		return self
	}

	/// Remove all the color
	@discardableResult public func removeAllColors() -> DSFFinderLabels {
		self.colors.removeAll()
		return self
	}

	/// Remove all the tags
	@discardableResult public func removeAllTags() -> DSFFinderLabels {
		self.tags.removeAll()
		return self
	}
}

// MARK: Swift helpers for setting tags/colors (replace)

public extension DSFFinderLabels {

	// MARK: Set Color(s)

	/// Replace the existing colors with the specified color
	@discardableResult
	@inlinable func set(_ color: ColorIndex) -> DSFFinderLabels {
		return self.set([color])
	}

	/// Replace the existing colors with the specified colors
	@discardableResult
	@inlinable func set(_ colors: [ColorIndex]) -> DSFFinderLabels {
		self.colors = Set(colors)
		return self
	}

	// MARK: Set Tag(s)

	/// Replace the existing colors with the specified colors
	@discardableResult
	@inlinable func set(_ tag: String) -> DSFFinderLabels {
		return self.set([tag])
	}

	/// Replace the existing tags with the specified tags
	@discardableResult
	@inlinable func set(_ tags: [String]) -> DSFFinderLabels {
		self.tags = Set(tags)
		return self
	}
}

public extension DSFFinderLabels {

	// MARK: Insert and remove color(s)

	/// Add a color to the object
	@discardableResult
	@inlinable func insert(_ color: ColorIndex) -> DSFFinderLabels {
		return self.insert([color])
	}

	/// Add the specified color(s) to the object
	@discardableResult
	@inlinable func insert(_ colors: [ColorIndex]) -> DSFFinderLabels {
		self.colors.formUnion(colors)
		return self
	}

	/// Remove a color from the object
	@discardableResult
	@inlinable func remove(_ color: ColorIndex) -> DSFFinderLabels {
		return self.remove([color])
	}

	/// Remove the specified color(s) to the object
	@discardableResult
	@inlinable func remove(_ colors: [ColorIndex]) -> DSFFinderLabels {
		self.colors.subtract(colors)
		return self
	}

	// MARK: Insert and remove tags(s)

	/// Add a tag string to the object
	@discardableResult
	@inlinable func insert(_ tag: String) -> DSFFinderLabels {
		return self.insert([tag])
	}

	/// Add the specified tag string(s) to the object
	@discardableResult
	@inlinable func insert(_ tags: [String]) -> DSFFinderLabels {
		self.tags.formUnion(tags)
		return self
	}


	/// Remove a tag string from the object
	@discardableResult
	@inlinable func remove(_ tag: String) -> DSFFinderLabels {
		return self.remove([tag])
	}

	/// Remove the specified tag string(s) from the object
	@discardableResult
	@inlinable func remove(_ tags: [String]) -> DSFFinderLabels {
		self.tags.subtract(tags)
		return self
	}
}

// MARK: - Contains

@objc extension DSFFinderLabels {
	/// Is the specified color index set?
	///
	/// - Parameter colorIndex: the color index to check
	/// - Returns: true if the color exists, false otherwise
	public func contains(color: ColorIndex) -> Bool {
		return self.colors.contains(color)
	}

	/// Is the specified tag set?
	///
	/// - Parameter tag: The tag to check
	/// - Returns: true if the tag exists, false otherwise
	public func contains(tag: String) -> Bool {
		return self.tags.contains(tag)
	}
}
