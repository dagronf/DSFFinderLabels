//
//  AppDelegate.swift
//  DSFFinderLabelsDemo
//
//  Created by Darren Ford on 8/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

import DSFFinderLabels

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet var window: NSWindow!
	@IBOutlet var selectedPath: NSPathControl!

	@IBOutlet var finderColorButtons: DSFFinderColorGridView!

	@IBOutlet var finderTags: DSFFinderTagsField!

	private var activeSearch: DSFFinderLabels.Search?
	private var activeSearches: [DSFFinderLabels.Search] = []

	func applicationDidFinishLaunching(_: Notification) {
		self.selectedPath.url = nil

//		let t = DSFFinderLabels.AllActiveTags()
//		Swift.print(t)
//
//		let e = DSFFinderLabels.urlsContaining(DSFFinderLabels(colors: [.green]))
//		Swift.print(e)
//
//		let c = DSFFinderLabels.FinderColors
//		Swift.print(c)
//
//		let fl = DSFFinderLabels(colors: [.green], tags: [])
//		let d = DSFFinderLabels.urlsContaining(fl)
//		Swift.print(d)
//
//		let fl2 = DSFFinderLabels(colors: [.green], tags: ["cat"])
//		let d2 = DSFFinderLabels.urlsContaining(fl2, exactMatch: true)
//		Swift.print(d2)



//		let url = URL(fileURLWithPath: "/Users/dford/Desktop/Untitled.rtf")
//		try? url.addFinderColor(.blue)


//		t.forEach { label in
//			let s = DSFFinderLabels.Search.search(for: DSFFinderLabels(colors: [.green], tags: [label]), exactMatch: false) { urls in
//				Swift.print("*** \(label): \(urls)")
//			}
//
//			activeSearches.append(s)
//		}

//		Swift.print(NSWorkspace.shared.fileLabels)
//
//		NotificationCenter.default.addObserver(
//			forName: NSWorkspace.didChangeFileLabelsNotification,
//			object: NSWorkspace.shared,
//			queue: .main) { (notification) in
//			Swift.print("file labels changed!")
//		}

	}

	func applicationWillTerminate(_: Notification) {
		// Insert code here to tear down your application
	}

	@IBAction func loadURL(_: Any) {
		let openPanel = NSOpenPanel()

		openPanel.begin { (result) -> Void in
			if result == NSApplication.ModalResponse.OK {
				self.loaded(url: openPanel.url!)
			}
		}
	}

	func loaded(url: URL) {
		self.selectedPath.url = url
		let labels = url.finderLabels()

		self.finderColorButtons.setSelected(colors: labels.colors)

		self.finderTags.finderTags = Array(labels.tags)
	}

	@IBAction func reset(_: Any) {
		self.finderColorButtons.reset()
	}

	@IBAction func findMatching(_: Any) {
		let updated = DSFFinderLabels()

		let selected = self.finderColorButtons.selectedColors
		updated.colors = Set(selected)

		/// Set updated tags
		let itemTags = self.finderTags.finderTags
		updated.tags = Set(itemTags)

		self.activeSearch = updated.findAllMatching { results in
			print(results)
		}

//		let urls = updated.findAllMatching()
//		print(urls)
	}

	@IBAction func update(_: Any) {
		guard let url = self.selectedPath.url else {
			return
		}

		let updated = DSFFinderLabels()

		let selected = self.finderColorButtons.selectedColors
		updated.colors = Set(selected)

		/// Set updated tags
		updated.tags = Set(self.finderTags.objectValue as! [String])

		// Try to update
		try? url.setFinderLabels(updated)
	}
}
