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

	@IBOutlet weak var color0: CircleColorButton!
	@IBOutlet weak var color1: CircleColorButton!
	@IBOutlet weak var color2: CircleColorButton!
	@IBOutlet weak var color3: CircleColorButton!
	@IBOutlet weak var color4: CircleColorButton!
	@IBOutlet weak var color5: CircleColorButton!
	@IBOutlet weak var color6: CircleColorButton!
	@IBOutlet weak var color7: CircleColorButton!

	@IBOutlet weak var finderTags: NSTokenField!

	private func configureButton(button: CircleColorButton, color: NSColor)
	{
		button.darkColor = color
		button.lightColor = color
		button.state = .off
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		let colors = DSFFinderLabels.FinderColors

		self.configureButton(button: color0, color: colors.color(for: .none)!.color)
		self.configureButton(button: color1, color: colors.color(for: .grey)!.color)
		self.configureButton(button: color2, color: colors.color(for: .green)!.color)
		self.configureButton(button: color3, color: colors.color(for: .purple)!.color)
		self.configureButton(button: color4, color: colors.color(for: .blue)!.color)
		self.configureButton(button: color5, color: colors.color(for: .yellow)!.color)
		self.configureButton(button: color6, color: colors.color(for: .red)!.color)
		self.configureButton(button: color7, color: colors.color(for: .orange)!.color)

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

		color0.state = labels.hasColorIndex(.none) ? .on : .off
		color1.state = labels.hasColorIndex(.grey) ? .on : .off
		color2.state = labels.hasColorIndex(.green) ? .on : .off
		color3.state = labels.hasColorIndex(.purple) ? .on : .off
		color4.state = labels.hasColorIndex(.blue) ? .on : .off
		color5.state = labels.hasColorIndex(.yellow) ? .on : .off
		color6.state = labels.hasColorIndex(.red) ? .on : .off
		color7.state = labels.hasColorIndex(.orange) ? .on : .off

		self.finderTags.objectValue = Array(labels.tags)
	}

	@IBAction func reset(_ sender: Any)
	{
		color0.state = .off
		color1.state = .off
		color2.state = .off
		color3.state = .off
		color4.state = .off
		color5.state = .off
		color6.state = .off
		color7.state = .off
	}

	@IBAction func update(_ sender: Any)
	{
		guard let url = self.selectedPath.url else
		{
			return
		}

		let updated = DSFFinderLabels()

		/// Set updated colors
		if color0.state == .on {
			updated.colors.insert(.none)
		}
		if color1.state == .on {
			updated.colors.insert(.grey)
		}
		if color2.state == .on {
			updated.colors.insert(.green)
		}
		if color3.state == .on {
			updated.colors.insert(.purple)
		}
		if color4.state == .on {
			updated.colors.insert(.blue)
		}
		if color5.state == .on {
			updated.colors.insert(.yellow)
		}
		if color6.state == .on {
			updated.colors.insert(.red)
		}
		if color7.state == .on {
			updated.colors.insert(.orange)
		}

		/// Set updated tags
		updated.tags = Set(self.finderTags.objectValue as! [String])

		// Try to update
		try? url.setFinderLabels(updated)
	}

}

