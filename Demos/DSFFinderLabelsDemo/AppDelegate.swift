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

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var selectedPath: NSPathControl!

	@IBOutlet weak var finderColorButtons: DSFFinderColorGridView!

	@IBOutlet weak var finderTags: DSFFinderTagsField!

	private var activeSearch: DSFFinderLabels.Search?


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		self.selectedPath.url = nil
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	@IBAction func loadURL(_ sender: Any)
	{
		let openPanel = NSOpenPanel()

		openPanel.begin { (result) -> Void in
			if result == NSApplication.ModalResponse.OK
			{
				_ = self.loaded(url: openPanel.url!)
			}
		}
	}

	func loaded(url: URL)
	{
		self.selectedPath.url = url
		let labels = url.finderLabels()

		self.finderColorButtons.setSelected(colors: labels.colors)

		self.finderTags.finderTags = Array(labels.tags)
	}

	@IBAction func reset(_ sender: Any)
	{
		self.finderColorButtons.reset()
	}

	@IBAction func findMatching(_ sender: Any)
	{
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

	@IBAction func update(_ sender: Any)
	{
		guard let url = self.selectedPath.url else
		{
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

