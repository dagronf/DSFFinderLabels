//
//  DSFFinderLabels+Search.swift
//  DSFFinderLabels
//
//  Created by Darren Ford on 10/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

public extension DSFFinderLabels
{
	public class Search
	{

		/// Create and asynchronously search for all items matching the specified tags
		///
		/// - Parameters:
		///   - labels: The labels to search for
		///   - exactMatch: Only return matches that _exactly_ match ALL of the tags
		///   - completion: called when the search is complete
		/// - Returns: A search object
		static func search(for labels: DSFFinderLabels, exactMatch: Bool = true, completion: @escaping ((Set<URL>) -> Void)) -> Search {
			let obj = Search(searchTags: labels.allLabels(), exactMatch: exactMatch, completion: completion)
			obj.internalSearch(for: labels)
			return obj
		}

		private let exactMatch: Bool
		private let metadataSearch = NSMetadataQuery()
		private let searchTags: Set<String>
		private let completion: ((Set<URL>) -> Void)

		private init() {
			self.searchTags = Set([])
			fatalError("Shouldn't be called")
		}

		private init(searchTags: Set<String>, exactMatch: Bool = true, completion: @escaping ((Set<URL>) -> Void)) {
			self.searchTags = searchTags
			self.completion = completion
			self.exactMatch = exactMatch
		}

		deinit {
			self.metadataSearch.stop()
			NotificationCenter.default.removeObserver(self)
		}

		private func internalSearch(for labels: DSFFinderLabels) {
			NotificationCenter.default.addObserver(
				forName: NSNotification.Name.NSMetadataQueryDidFinishGathering,
				object: self.metadataSearch,
				queue: nil) { [weak self] (notification) in
				self?.complete()
			}

			let pred = NSPredicate.init(format: labels.queryString())
			self.metadataSearch.predicate = pred
			self.metadataSearch.start()
		}

		private func complete() {
			self.metadataSearch.stop()

			var results = Set<URL>()
			for count in 0 ..< self.metadataSearch.resultCount
			{
				guard let result = self.metadataSearch.result(at: count) as? NSMetadataItem else {
					continue
				}

				if let path = result.value(forAttribute: "kMDItemPath") as? String,
					let tags = result.value(forAttribute: "kMDItemUserTags") as? [String] {
					if !self.exactMatch || Set(tags) == self.searchTags {
						results.insert(URL(fileURLWithPath: path))
					}
				}
			}

			self.completion(results)
		}
	}


	/// Find all files in scope that match the tags
	///
	/// - Parameters:
	///   - exactMatch: If true, matches only when ALL tags are present, else matches when ANY of the tags match
	///   - completion: called with the search results
	/// - Returns: search object
	public func findAllMatching(exactMatch: Bool = true, completion: @escaping ((Set<URL>) -> Void)) -> Search?
	{
		let tags = self.allLabels()
		if tags.count == 0
		{
			return nil
		}

		return Search.search(for: self, exactMatch: exactMatch, completion: completion)
	}


	/// Return all the tags that are current in use in the user's default search scope
	static public func AllActiveTags() -> Set<String> {
		let query = MDQueryCreate(kCFAllocatorDefault, "kMDItemUserTags == *" as CFString, nil, nil)
		MDQueryExecute(query, CFOptionFlags(kMDQuerySynchronous.rawValue))

		var result = Set<String>()
		let count = MDQueryGetResultCount(query);
		for i in 0 ..< count {
			let rawPtr = MDQueryGetResultAtIndex(query, i)
			let item = Unmanaged<MDItem>.fromOpaque(rawPtr!).takeUnretainedValue()
			if let tags = MDItemCopyAttribute(item, "kMDItemUserTags" as CFString) as? [String] {
				result.formUnion(Set(tags))
			}
		}

		return result.filter { DSFFinderLabels.FinderColors.color(labelled: $0) == nil }
	}


	private func allLabels() -> Set<String>
	{
		var arr = Set<String>()
		for colorIndex in self.colors
		{
			let color = DSFFinderLabels.FinderColors.color(for: colorIndex)
			arr.insert(color!.label)
		}
		return arr.union(self.tags)
	}

	private func queryString() -> String
	{
		let arr = self.allLabels().map { "kMDItemUserTags = '\($0)'" }
		return "(" + (arr as NSArray).componentsJoined(by: " && ") + ")"
	}

}
