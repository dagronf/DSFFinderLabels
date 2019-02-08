//
//  DSFFinderLabelsTests.swift
//  DSFFinderLabelsTests
//
//  Created by Darren Ford on 8/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import XCTest
@testable import DSFFinderLabels

class DFUtils
{
	class TempFile
	{
		let fileURL: URL = {
			let directory = NSTemporaryDirectory()
			let fileName = NSUUID().uuidString

			// This returns a URL? even though it is an NSURL class method
			return NSURL.fileURL(withPathComponents: [directory, fileName])! as URL
		}()

		deinit
		{
			try? FileManager.default.removeItem(at: fileURL)
		}
	}

	static func url(_ val: String) -> URL
	{
		return URL(string: val)!
	}
}


class DSFFinderLabelsTests: XCTestCase {

	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	private func getDummyFile() throws -> DFUtils.TempFile
	{
		let file = DFUtils.TempFile.init()
		let tempstr = "Hi this is a test"
		try tempstr.write(to: file.fileURL, atomically: false, encoding: .utf8)
		return file
	}

	func testSimpleAdd() {
		guard let file = try? self.getDummyFile() else {
			fatalError("Could not create temporary file")
		}

		// Because we created it just now, we shouldn't have any tags or colors
		let labels = DSFFinderLabels(fileURL: file.fileURL)
		XCTAssertEqual(0, labels.tags.count)
		XCTAssertEqual(0, labels.colors.count)

		// Update the labels and colors on the file
		labels.colors.insert(.orange)
		labels.colors.insert(.yellow)
		labels.colors.insert(.green)
		labels.tags.insert("In Progress")
		labels.tags.insert("Work Related")

		guard let _ = try? file.fileURL.setFinderLabels(labels) else {
			fatalError("Could not update file with new tags and colors")
		}

		// Check that the labels and tags updated

		let updatedLabels = file.fileURL.finderLabels()
		XCTAssertEqual(2, updatedLabels.tags.count)
		XCTAssertTrue(updatedLabels.tags.contains("In Progress"))
		XCTAssertTrue(updatedLabels.tags.contains("Work Related"))

		XCTAssertEqual(3, updatedLabels.colors.count)
		XCTAssertTrue(updatedLabels.colors.contains(.orange))
		XCTAssertTrue(updatedLabels.colors.contains(.yellow))
		XCTAssertTrue(updatedLabels.colors.contains(.green))

		// Remove a couple and check again

		updatedLabels.tags.remove("In Progress")
		updatedLabels.colors.remove(.orange)
		updatedLabels.colors.remove(.yellow)
		guard let _ = try? file.fileURL.setFinderLabels(updatedLabels) else {
			fatalError("Could not update file with new tags and colors")
		}

		let moreUpdatedLabels = file.fileURL.finderLabels()
		XCTAssertEqual(1, moreUpdatedLabels.tags.count)
		XCTAssertTrue(moreUpdatedLabels.tags.contains("Work Related"))
		XCTAssertEqual(1, updatedLabels.colors.count)
		XCTAssertTrue(updatedLabels.colors.contains(.green))
	}

	func testSimpleUpdateMultiple() {
		guard let file1 = try? self.getDummyFile(),
			let file2 = try? self.getDummyFile(),
			let file3 = try? self.getDummyFile()
			else {
				fatalError("Could not create temporary files")
		}

		let labels = DSFFinderLabels()
		labels.colors.insert(.green)
		labels.colors.insert(.orange)
		labels.tags.insert("Work Related")

		guard let _ = try? labels.update(urls: [file1.fileURL, file2.fileURL, file3.fileURL]) else {
			fatalError("Could not update temporary files")
		}

		let l1 = DSFFinderLabels(fileURL: file1.fileURL)
		XCTAssertEqual(l1.colors, Set([DSFFinderLabels.ColorIndex.green, DSFFinderLabels.ColorIndex.orange]))
		XCTAssertEqual(l1.tags, Set(["Work Related"]))
		let l2 = DSFFinderLabels(fileURL: file2.fileURL)
		XCTAssertEqual(l2.colors, Set([DSFFinderLabels.ColorIndex.green, DSFFinderLabels.ColorIndex.orange]))
		XCTAssertEqual(l2.tags, Set(["Work Related"]))
		let l3 = DSFFinderLabels(fileURL: file3.fileURL)
		XCTAssertEqual(l3.colors, Set([DSFFinderLabels.ColorIndex.green, DSFFinderLabels.ColorIndex.orange]))
		XCTAssertEqual(l3.tags, Set(["Work Related"]))
	}
}
