//
//  DSFFinderColorCircleButton.swift
//  DSFFinderLabels
//
//  Created by Darren Ford on 15/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

class DSFFinderColorCircleButton: NSButton {

	let selectionMax: CGFloat = 0.35

	private let outerLayer = CAShapeLayer()
	private let selectLayer = CAShapeLayer()
	private let shadowLayer = CALayer()

	/// Returns true if the system is set to increase contrast, false otherwise
	private func isHighContrast() -> Bool {
		return NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
	}

	/// Returns true if the system is NOT set to reduce motion (accessibility settings)
	private func shouldAnimate() -> Bool {
		return !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
	}

	/// The color to fill the circle
	var drawColor: NSColor? {
		didSet {
			self.outerLayer.fillColor = self.drawColor?.cgColor
			self.outerLayer.strokeColor = self.strokeColor
		}
	}

	/// The stroke color for the circle.
	var strokeColor: CGColor {
		if let _ = self.drawColor {
			return NSColor.quaternaryLabelColor.cgColor.copy(alpha: 0.2)!
		}
		return NSColor.quaternaryLabelColor.cgColor
	}

	/// Listener for state changes
	var stateObserver: NSKeyValueObservation?

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	public override func drawFocusRingMask() {
		let circlePath = NSBezierPath(ovalIn: self.bounds.insetBy(dx: 1, dy: 1))
		circlePath.fill()
	}

	// MARK: Layer updates

	override var wantsUpdateLayer: Bool {
		return true
	}

	override func updateLayer() {
		self.outerLayer.strokeColor = self.strokeColor
		self.outerLayer.setNeedsDisplay()
	}
}

// MARK: - Configuration

extension DSFFinderColorCircleButton {

	private func setup() {
		self.wantsLayer = true
		self.isBordered = false

		self.outerLayer.frame = self.bounds
		self.outerLayer.path = CGPath(ellipseIn: self.bounds.insetBy(dx: 3.5, dy: 3.5), transform: nil)
		self.outerLayer.fillColor = NSColor.clear.cgColor
		self.outerLayer.strokeColor = NSColor.secondaryLabelColor.cgColor
		self.layer?.addSublayer(self.outerLayer)

		self.selectLayer.frame = self.bounds
		self.selectLayer.path = CGPath(ellipseIn: self.bounds, transform: nil)
		self.selectLayer.fillColor = NSColor.white.cgColor

		self.shadowLayer.frame = self.bounds
		self.shadowLayer.shadowColor = NSColor.black.cgColor
		self.shadowLayer.shadowOffset = CGSize(width: 0.5, height: 1)
		self.shadowLayer.shadowRadius = 3
		self.shadowLayer.shadowOpacity = 0.4
		self.shadowLayer.backgroundColor = NSColor.clear.cgColor

		self.contrastSettingsDidChange()

		// Listen for accessibility changes
		NSWorkspace.shared.notificationCenter.addObserver(
			forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
			object: NSWorkspace.shared,
			queue: nil
		) { _ in
			self.contrastSettingsDidChange()
		}

		// Listen to state changes so that we can update ourselves appropriately
		self.stateObserver = self.observe(
			\.cell?.state,
			options: [.new]
		) { [weak self] _, _ in
			self?.updateForNewState(animated: true)
		}
	}

	private func contrastSettingsDidChange() {
		self.selectLayer.removeFromSuperlayer()
		self.shadowLayer.removeFromSuperlayer()
		if NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast {
			self.layer?.addSublayer(self.selectLayer)
			self.selectLayer.strokeColor = NSColor.black.cgColor
			self.selectLayer.lineWidth = 1.0
		}
		else {
			self.selectLayer.strokeColor = NSColor.secondaryLabelColor.cgColor
			self.selectLayer.lineWidth = 1.0
			self.shadowLayer.insertSublayer(self.selectLayer, at: 0)
			self.layer?.addSublayer(self.shadowLayer)
		}
		self.updateLayer()
	}
}

// MARK: - State change updates

extension DSFFinderColorCircleButton {

	private func animateTurnOn() {
		assert(self.state == .on)
		let order = [0.0, 0.4, 0.3, self.selectionMax]
		let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
		bounceAnimation.values = order
		bounceAnimation.duration = TimeInterval(0.25)
		bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
		bounceAnimation.isRemovedOnCompletion = false
		bounceAnimation.fillMode = .forwards
		self.selectLayer.add(bounceAnimation, forKey: "transform.scale")
	}

	private func animateTurnOff() {
		assert(self.state == .off)

		let outAnimation = CABasicAnimation(keyPath: "transform.scale")
		outAnimation.fromValue = self.selectionMax
		outAnimation.toValue = 0.0
		outAnimation.duration = TimeInterval(0.1)
		outAnimation.isRemovedOnCompletion = false
		outAnimation.fillMode = .forwards
		outAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
		self.selectLayer.add(outAnimation, forKey: "transform.scale")
	}

	private func updateForNewState(animated: Bool) {
		let shouldAnimate = self.shouldAnimate() && animated

		self.selectLayer.removeAllAnimations()

		let isNowOn = (self.state == .on)

		if shouldAnimate {
			isNowOn ? self.animateTurnOn() : self.animateTurnOff()
		}
		else {
			let scale: CGFloat = isNowOn ? self.selectionMax : 0.0
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			self.selectLayer.transform = CATransform3DMakeScale(scale, scale, 1)
			CATransaction.commit()
		}
	}

	override func viewDidMoveToWindow() {
		self.updateForNewState(animated: false)
	}
}
