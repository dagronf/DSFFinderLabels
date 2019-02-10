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
			let obj = Search(searchTags: labels.allTags(), exactMatch: exactMatch, completion: completion)
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
		let tags = self.allTags()
		if tags.count == 0
		{
			return nil
		}

		return Search.search(for: self, exactMatch: exactMatch, completion: completion)
	}


//	public func findAllMatching() -> [URL]
//	{
//		var result = [URL]()
//
//		guard self.allTags().count > 0 else
//		{
//			return []
//		}
//
//		let query = MDQueryCreate(kCFAllocatorDefault, self.queryString() as CFString, nil, nil)
//
//		MDQuerySetSearchScope(query, [kMDQueryScopeHome] as CFArray, 0)
//
//		MDQueryExecute(query, CFOptionFlags(kMDQuerySynchronous.rawValue))
//
//		let count = MDQueryGetResultCount(query);
//		for i in 0 ..< count {
//			let rawPtr = MDQueryGetResultAtIndex(query, i)
//			let item = Unmanaged<MDItem>.fromOpaque(rawPtr!).takeUnretainedValue()
//			if let tags = MDItemCopyAttribute(item, "kMDItemUserTags" as CFString) as? [String],
//				let path = MDItemCopyAttribute(item, kMDItemPath) as? String {
//
//				if Set(tags) == Set(allTags())
//				{
//					result.append(URL(fileURLWithPath: path))
//				}
//			}
//		}
//		return result
//	}

	private func allTags() -> Set<String>
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
		let arr = self.allTags().map { "kMDItemUserTags = '\($0)'" }
		return "(" + (arr as NSArray).componentsJoined(by: " && ") + ")"
	}

}
