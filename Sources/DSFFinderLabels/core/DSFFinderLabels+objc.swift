//
//  DSFFinderLabels+objc.swift
//  DSFFinderLabels
//
//  Created by Darren Ford on 9/2/19.
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

// Swift cannot share Set<ColorIndex> automatically with objc, as it cannot represent the
// type in that language

@objc public extension DSFFinderLabels {
	// MARK: (Obj-C) Tags access and update

	/// Insert the tag string
	func insertTag(tag: String) {
		self.tags.insert(tag)
	}

	/// Remove the tag
	func removeTag(tag: String) {
		self.tags.remove(tag)
	}

	/// Add the specified tags to the set of tags
	func insertTags(tags: Set<String>) {
		self.tags.formUnion(tags)
	}

	/// Retrieve the set of tags
	func getTags() -> Set<String> {
		return Set(self.tags)
	}

	/// Set the tags to the specified set of tags
	func setTags(tags: Set<String>) {
		self.tags = Set(tags)
	}

	// MARK: (Obj-C) Color access and update

	@nonobjc private func convert(from colorValues: Set<NSNumber>) throws -> Set<ColorIndex> {
		var result = Set<ColorIndex>()
		for colorVal in colorValues {
			guard let color = ColorIndex(rawValue: colorVal.intValue) else {
				throw NSError(domain: "Bad index", code: -1, userInfo: nil)
			}
			result.insert(color)
		}
		return result
	}

	/// Add the specified color index to the set of color indexes
	func addColor(index: ColorIndex) {
		self.colors.insert(index)
	}

	/// Add the specified color indexes to the set of color indexes
	func addColors(colorValues: Set<NSNumber>) throws {
		let result = try self.convert(from: colorValues)
		self.colors.formUnion(result)
	}

	/// Remove the specified color index from the set of color indexes
	func removeColor(index: ColorIndex) {
		self.colors.remove(index)
	}

	/// Remove the specified color indexes (as NSNumbers) from the set of color indexes
	///
	/// - Parameter colorValues: the color indexes to set
	/// - Throws: If the colorValues set contains an invalid color index
	func removeColorValues(colorValues: Set<NSNumber>) throws {
		let result = try self.convert(from: colorValues)
		self.colors.subtract(result)
	}

	/// Returns the set of color indexes as a set of NSNumber
	func getColorValues() -> Set<NSNumber> {
		return Set(self.colors.map { NSNumber(value: $0.rawValue) })
	}

	/// Sets the current color indexes (objc)
	///
	/// - Parameter colorValues: The color indexes to set
	/// - Throws: If the set contains an invalid color index value
	func setColorsValues(colorValues: Set<NSNumber>) throws {
		self.colors = try self.convert(from: colorValues)
	}
}

// MARK: - NSURL Extension

@objc public extension NSURL {
	/// Returns the finder labels for the current NSURL
	func finderLabels() -> DSFFinderLabels {
		return DSFFinderLabels(fileURL: self as URL)
	}

	/// Set the labels defined by 'finderLabels' to the NSURL
	func setFinderLabels(finderLabels: DSFFinderLabels) throws {
		try finderLabels.update(url: self as URL)
	}

	func setFinderLabels(colorValues: [NSNumber] = [], tags: [String] = []) throws {
		var vals = [DSFFinderLabels.ColorIndex]()
		for value in colorValues {
			guard let val = DSFFinderLabels.ColorIndex(rawValue: value.intValue) else {
				throw NSError(domain: "Bad index", code: -1, userInfo: nil)
			}
			vals.append(val)
		}

		let labels = DSFFinderLabels(colors: vals, tags: tags)
		try labels.update(url: self as URL)
	}
}
