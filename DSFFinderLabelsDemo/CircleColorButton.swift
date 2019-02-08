//
//  CircleColorButton.swift
//  DSFFinderLabelsDemo
//
//  Created by Darren Ford on 8/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

public class CircleColorButton: NSButton {

	var darkColor = NSColor(calibratedRed: 0.201, green: 0.404, blue: 0.192, alpha: 1)
	{
		didSet
		{
			self.needsDisplay = true
		}
	}
	var lightColor = NSColor(calibratedRed: 0.304, green: 0.601, blue: 0.294, alpha: 1)
	{
		didSet
		{
			self.needsDisplay = true
		}
	}

	public override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		let rect = NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
		let insetRect = rect.insetBy(dx: 5, dy: 5)
		let circlePath = NSBezierPath(ovalIn: insetRect)

		var fillColor: NSColor
		var strokeColor: NSColor
		circlePath.fill()
		if self.isHighlighted {
			strokeColor = self.darkColor
			fillColor = self.lightColor
		} else {
			strokeColor = self.lightColor
			fillColor = self.darkColor
		}

		strokeColor.setStroke()
		circlePath.lineWidth = 1
		circlePath.stroke()
		fillColor.setFill()
		circlePath.fill()

		// Draw selection

		if self.state == .on
		{
			let circlePath = NSBezierPath(ovalIn: rect.insetBy(dx: 2, dy: 2))
			circlePath.lineWidth = 2
			NSColor.white.setStroke()
			circlePath.stroke()
		}
	}
}
