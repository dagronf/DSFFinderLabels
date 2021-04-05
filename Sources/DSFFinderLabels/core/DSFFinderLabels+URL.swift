//
//  DSFFinderLabels+URL.swift
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

//
//  URL Extensions for DSFFinderLabels
//

import Foundation

public extension URL {
	/// Returns the finder labels for the current URL
	@inlinable func finderLabels() -> DSFFinderLabels {
		return DSFFinderLabels(fileURL: self)
	}

	/// Assign the labels defined by 'finderLabels' to the URL
	@inlinable func setFinderLabels(_ finderLabels: DSFFinderLabels) throws {
		try finderLabels.update(url: self)
	}

	@inlinable func setFinderLabels(colors: [DSFFinderLabels.ColorIndex] = [], tags: [String] = []) throws {
		let labels = DSFFinderLabels(colors: colors, tags: tags)
		try labels.update(url: self)
	}
}

// MARK: Quick

public extension URL {

	/// Set a tag color for the url
	@inlinable func addFinderColor(_ color: DSFFinderLabels.ColorIndex) throws {
		try self.finderLabels()
			.insert(color)
			.update(url: self)
	}

	/// Unset a tag color for the url
	@inlinable func removeFinderColor(_ color: DSFFinderLabels.ColorIndex) throws {
		try self.finderLabels()
			.remove(color)
			.update(url: self)
	}

	@inlinable func addFinderTag(_ tag: String) throws {
		try self.finderLabels()
			.insert(tag)
			.update(url: self)
	}

	@inlinable func removeFinderTag(_ tag: String) throws {
		try self.finderLabels()
			.remove(tag)
			.update(url: self)
	}

	@inlinable func addFinderLabels(colors: [DSFFinderLabels.ColorIndex] = [], labels: [String] = []) throws {
		try self.finderLabels()
			.insert(colors)
			.insert(labels)
			.update(url: self)
	}

	@inlinable func removeFinderLabels(colors: [DSFFinderLabels.ColorIndex] = [], labels: [String] = []) throws {
		try self.finderLabels()
			.remove(colors)
			.remove(labels)
			.update(url: self)
	}
}

// MARK: Update

public extension DSFFinderLabels {
	/// Update the URL with the current label values
	@objc func update(url: URL) throws {
		let vals = self.allLabels
		try (url as NSURL).setResourceValue(Array(vals), forKey: .tagNamesKey)
	}

	/// Update the given URLs with the current label values
	@objc func update(urls: [URL]) throws {
		try urls.forEach { try self.update(url: $0) }
	}

	/// Replace the current values with the labels for the specified URL
	///
	/// - Parameter fileURL: The URL to load the new values from
	@objc func reset(with fileURL: URL) {
		// Clear out all the stored values
		self.removeAll()

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
}
