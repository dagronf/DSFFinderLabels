//
//  DSFFinderLabels+Search.swift
//  DSFFinderLabels
//
//  Created by Darren Ford on 10/2/19.
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

//
//  Label and color search
//

@objc public protocol DSFFinderLabelsSearchObserver: NSObjectProtocol {
	@objc func cancel()
}

@objc public extension DSFFinderLabels {

	/// Search callback type.  Returns a set of URLs matching the query if successful, otherwise nil
	typealias SearchCompletionCallbackType = (Set<URL>?) -> Void

	/// The type of matching to perform
	@objc(DSFFinderLabelsMatchType) enum MatchType: Int {
		/// Match any of the specified labels
		case any = 0
		/// Result must contain all the labels (ie. [blue, green, red] matches [blue, green, red, cat, dog])
		case all = 1
		/// Match all the labels exactly
		case exact = 2
	}

	/// Create and asynchronously search for all items matching the specified tags
	///
	/// - Parameters:
	///   - labels: The labels to search for
	///   - matchType: The type of matching to perform
	///   - completion: called when the search is complete
	/// - Returns: A search object
	@objc static func search(for labels: DSFFinderLabels,
									 matchType: MatchType = .any,
									 completion: @escaping SearchCompletionCallbackType) -> DSFFinderLabelsSearchObserver {
		let obj = Search(searchTags: labels.allLabels, matchType: matchType, completion: completion)
		obj.internalSearch(for: labels)
		return obj
	}

	/// Find all files in scope that match the tags
	///
	/// - Parameters:
	///   - exactMatch: If true, matches only when ALL tags are present, else matches when ANY of the tags match
	///   - completion: called with the search results
	/// - Returns: search object
	func findAllMatching(matchType: MatchType = .any, completion: @escaping SearchCompletionCallbackType) -> DSFFinderLabelsSearchObserver? {
		guard self.allLabels.count > 0 else {
			completion(Set())
			return nil
		}
		return Self.search(for: self, matchType: matchType, completion: completion)
	}

	/// Return all the tags that are current in use in the user's default search scope
	static func AllActiveTags() -> Set<String> {
		let query = MDQueryCreate(kCFAllocatorDefault, "kMDItemUserTags == *" as CFString, nil, nil)
		MDQueryExecute(query, CFOptionFlags(kMDQuerySynchronous.rawValue))

		var result = Set<String>()
		let count = MDQueryGetResultCount(query)
		for i in 0 ..< count {
			let rawPtr = MDQueryGetResultAtIndex(query, i)
			let item = Unmanaged<MDItem>.fromOpaque(rawPtr!).takeUnretainedValue()
			if let tags = MDItemCopyAttribute(item, "kMDItemUserTags" as CFString) as? [String] {
				result.formUnion(Set(tags))
			}
		}

		return result.filter { DSFFinderLabels.FinderColors.color(labelled: $0) == nil }
	}

	private func queryString(exactMatch: Bool = true) -> String {
		let arr = self.allLabels.map { "kMDItemUserTags = '\($0)'" }
		return arr.joined(separator: exactMatch ? " && " : " || ")
	}
}

public extension DSFFinderLabels {

	/// A search class
	@objc(DSFFinderLabelsSearch) class Search: NSObject, DSFFinderLabelsSearchObserver {
		private let searchTags: Set<String>
		private let matchType: MatchType
		private let completion: (Set<URL>?) -> Void

		private let metadataSearch = NSMetadataQuery()
		private var observer: NSObjectProtocol?

		fileprivate init(searchTags: Set<String>,
							  matchType: MatchType = .any,
							  completion: @escaping SearchCompletionCallbackType) {
			self.searchTags = searchTags
			self.completion = completion
			self.matchType = matchType
		}

		deinit {
			self.metadataSearch.stop()
			NotificationCenter.default.removeObserver(self)
			self.observer = nil
		}

		fileprivate func internalSearch(for labels: DSFFinderLabels) {
			self.observer = NotificationCenter.default.addObserver(
				forName: NSNotification.Name.NSMetadataQueryDidFinishGathering,
				object: self.metadataSearch,
				queue: nil
			) { [weak self] _ in
				self?.complete()
			}

			let pred = NSPredicate(format: labels.queryString(exactMatch: self.matchType != .any))
			self.metadataSearch.predicate = pred
			self.metadataSearch.start()
		}

		/// Cancel the current search.
		///
		/// Will call 'completion' callback with nil to indicate complete
		public func cancel() {
			self.metadataSearch.stop()
			self.observer = nil

			// Call nil on the completion handler
			self.completion(nil)
		}

		private func complete() {

			self.metadataSearch.stop()
			self.observer = nil

			var results = Set<URL>()
			for count in 0 ..< self.metadataSearch.resultCount {
				guard let result = self.metadataSearch.result(at: count) as? NSMetadataItem else {
					continue
				}
				if let path = result.value(forAttribute: "kMDItemPath") as? String,
					let tags = result.value(forAttribute: "kMDItemUserTags") as? [String] {
					switch(self.matchType) {
					case .any:
						results.insert(URL(fileURLWithPath: path))
					case .all:
						results.insert(URL(fileURLWithPath: path))
					case .exact:
						if Set(tags) == self.searchTags {
							results.insert(URL(fileURLWithPath: path))
						}
					}
				}
			}

			self.completion(results)
		}
	}

}

#endif
