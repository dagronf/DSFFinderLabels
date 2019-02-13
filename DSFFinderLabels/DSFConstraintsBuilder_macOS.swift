//
//  DSFConstraintsBuilder_macOS.swift
//  DSFFinderLabels
//
//  Created by Darren Ford on 10/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

@objc public class DSFConstraintsBuilder: NSObject {

	weak var view: NSView?
	init(view: NSView) {
		super.init()
		self.view = view
		self.view?.translatesAutoresizingMaskIntoConstraints = false
	}

	@discardableResult
	func constrainDimension(_ constant: CGFloat, attribute: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint? {
		guard let control = self.view else {
			return nil
		}

		control.translatesAutoresizingMaskIntoConstraints = false

		let c = NSLayoutConstraint(
			item: control, attribute: attribute,
			relatedBy: relation,
			toItem: nil, attribute: .notAnAttribute,
			multiplier: 1, constant: constant)
		control.addConstraint(c)
		return c
	}

	@discardableResult
	public func width(_ constant: CGFloat, relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint?
	{
		return self.constrainDimension(constant, attribute: .width, relation: relation)
	}

	@discardableResult
	public func height(_ constant: CGFloat, relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint? {
		return self.constrainDimension(constant, attribute: .height, relation: relation)
	}

	@discardableResult
	func equalAttribute(_ view1: NSView,attribute: NSLayoutConstraint.Attribute, _ view2: NSView, constant: CGFloat) -> NSLayoutConstraint? {
		guard let v = self.view else {
			return nil
		}

		view1.translatesAutoresizingMaskIntoConstraints = false
		view2.translatesAutoresizingMaskIntoConstraints = false

		let c = NSLayoutConstraint(item: view1, attribute: attribute,
								   relatedBy: .equal,
								   toItem: view2, attribute: attribute,
								   multiplier: 1.0, constant: constant)
		v.addConstraint(c)
		return c
	}

	@discardableResult
	public func center(attribute: NSLayoutConstraint.Attribute, view1: NSView, in view2: NSView, constant: CGFloat = 0) -> NSLayoutConstraint? {
		guard let v = self.view else {
			return nil
		}

		view1.translatesAutoresizingMaskIntoConstraints = false
		view2.translatesAutoresizingMaskIntoConstraints = false

		let c = NSLayoutConstraint(item: view1, attribute: attribute,
								   relatedBy: .equal,
								   toItem: view2, attribute: attribute,
								   multiplier: 1.0, constant: constant)
		v.addConstraint(c)
		return c
	}

	@discardableResult
	public func center(attribute: NSLayoutConstraint.Attribute, view1: NSView, constant: CGFloat = 0) -> NSLayoutConstraint? {
		guard let v = self.view else {
			return nil
		}

		view1.translatesAutoresizingMaskIntoConstraints = false

		let c = NSLayoutConstraint(item: view1, attribute: attribute,
								   relatedBy: .equal,
								   toItem: v, attribute: attribute,
								   multiplier: 1.0, constant: constant)
		v.addConstraint(c)
		return c
	}

	@discardableResult
	public func centerX(_ view1: NSView, in view2: NSView, offset: CGFloat = 0) -> NSLayoutConstraint? {
		return self.center(attribute: .centerX, view1: view1, in: view2, constant: offset)
	}

	@discardableResult
	public func centerY(_ view1: NSView, in view2: NSView, offset: CGFloat = 0) -> NSLayoutConstraint? {
		return self.center(attribute: .centerX, view1: view1, in: view2, constant: offset)
	}

	@discardableResult
	public func attach(from view1: NSView, attribute1: NSLayoutConstraint.Attribute,
					   to view2: NSView, attribute2: NSLayoutConstraint.Attribute,
					   constant: CGFloat = 0) -> NSLayoutConstraint? {
		guard let v = self.view else {
			return nil
		}

		let c = NSLayoutConstraint(item: view1, attribute: attribute1,
								   relatedBy: .equal,
								   toItem: view2, attribute: attribute2,
								   multiplier: 1.0, constant: constant)
		v.addConstraint(c)
		return c
	}

	private func makeEqualEdge(view: NSView, attribute: NSLayoutConstraint.Attribute,
						  related: NSLayoutConstraint.Relation, constant: CGFloat = 0) -> NSLayoutConstraint? {
		guard let v = self.view else {
			return nil
		}
		view.translatesAutoresizingMaskIntoConstraints = false
		let i1 = NSLayoutConstraint(item: v, attribute: attribute,
									relatedBy: related,
									toItem: v, attribute: attribute,
									multiplier: 1.0, constant: constant)
		v.addConstraint(i1)
		return i1
	}

	public func left(view: NSView, related: NSLayoutConstraint.Relation, constant: CGFloat = 0) -> NSLayoutConstraint? {
		return self.makeEqualEdge(view: view, attribute: .left, related: related, constant: constant)
	}

	public func right(view: NSView, related: NSLayoutConstraint.Relation, constant: CGFloat = 0) -> NSLayoutConstraint? {
		return self.makeEqualEdge(view: view, attribute: .right, related: related, constant: constant)
	}

	public func top(view: NSView, related: NSLayoutConstraint.Relation, constant: CGFloat = 0) -> NSLayoutConstraint? {
		return self.makeEqualEdge(view: view, attribute: .top, related: related, constant: constant)
	}

	public func bottom(view: NSView, related: NSLayoutConstraint.Relation, constant: CGFloat = 0) -> NSLayoutConstraint? {
		return self.makeEqualEdge(view: view, attribute: .bottom, related: related, constant: constant)
	}

	@discardableResult
	@objc public func pin(view: NSView, edgeInsets: NSEdgeInsets = NSEdgeInsets()) -> [NSLayoutConstraint]?
	{
		guard let l1 = self.left(view: view, related: .equal, constant: edgeInsets.left),
			let l2 = self.right(view: view, related: .equal, constant: edgeInsets.right),
			let l3 = self.top(view: view, related: .equal, constant: edgeInsets.top),
			let l4 = self.bottom(view: view, related: .equal, constant: edgeInsets.bottom) else
		{
			return nil
		}
		return [l1, l2, l3, l4]
	}

	@discardableResult
	public func add(_ item1: (NSView, NSLayoutConstraint.Attribute),
					_ item2: (NSView, NSLayoutConstraint.Attribute),
					constant: (NSLayoutConstraint.Relation, CGFloat) = (.equal, 0)) -> NSLayoutConstraint? {
		guard let v = self.view else {
			return nil
		}

		item1.0.translatesAutoresizingMaskIntoConstraints = false
		item2.0.translatesAutoresizingMaskIntoConstraints = false

		let c = NSLayoutConstraint(item: item1.0, attribute: item1.1,
								   relatedBy: constant.0,
								   toItem: item2.0, attribute: item2.1,
								   multiplier: 1.0, constant: constant.1)
		v.addConstraint(c)
		return c
	}

	@discardableResult
	@objc public func equal(_ attribute: NSLayoutConstraint.Attribute, _ view1: NSView, _ view2: NSView, constant: CGFloat = 0) -> NSLayoutConstraint? {
		return equalAttribute(view1, attribute: attribute, view2, constant: constant)
	}


	@discardableResult
	@objc public func equalLeading(_ view1: NSView, _ view2: NSView, constant: CGFloat = 0) -> NSLayoutConstraint? {
		return equalAttribute(view1, attribute: .leading, view2, constant: constant)
	}

	@discardableResult
	@objc public func equalTrailing(_ view1: NSView, _ view2: NSView, constant: CGFloat = 0) -> NSLayoutConstraint? {
		return equalAttribute(view1, attribute: .trailing, view2, constant: constant)
	}

	@discardableResult
	@objc public func equalBottom(_ view1: NSView, _ view2: NSView, constant: CGFloat = 0) -> NSLayoutConstraint? {
		return equalAttribute(view1, attribute: .trailing, view2, constant: constant)
	}
}

public extension DSFConstraintsBuilder
{
	public typealias Relator = (NSLayoutConstraint.Relation, CGFloat, NSView)

	@discardableResult
	public func vStack(
		_ views: [Relator],
		_ relation: NSLayoutConstraint.Relation,
		_ offset: CGFloat) -> [NSLayoutConstraint]?
	{
		guard let v = self.view,
			views.count > 0 else {
				return nil
		}

		var arr = [NSLayoutConstraint]()

		let c = NSLayoutConstraint(item: views[0].2, attribute: .top,
								   relatedBy: views[0].0,
								   toItem: v, attribute: .top,
								   multiplier: 1.0, constant: views[0].1)
		arr.append(c)

		var prev = views[0].2
		for item in views[1..<views.count]
		{
			let c1 = NSLayoutConstraint(item: item.2, attribute: .top,
										relatedBy: item.0,
										toItem: prev, attribute: .bottom,
										multiplier: 1.0, constant: item.1)
			arr.append(c1)
			prev = item.2
		}

		let c3 = NSLayoutConstraint(item: v, attribute: .bottom,
									relatedBy: relation,
									toItem: views.last!.2, attribute: .bottom,
									multiplier: 1.0, constant: -offset)
		arr.append(c3)
		v.addConstraints(arr)
		return arr
	}

	@discardableResult
	public func hStack(
		_ views: [Relator],
		_ relation: NSLayoutConstraint.Relation,
		_ offset: CGFloat) -> [NSLayoutConstraint]?
	{
		guard let v = self.view,
			views.count > 0 else {
				return nil
		}

		var arr = [NSLayoutConstraint]()

		let c = NSLayoutConstraint(item: views[0].2, attribute: .left,
								   relatedBy: views[0].0,
								   toItem: v, attribute: .left,
								   multiplier: 1.0, constant: views[0].1)
		arr.append(c)

		var prev = views[0].2
		for item in views[1..<views.count]
		{
			let c1 = NSLayoutConstraint(item: item.2, attribute: .left,
										relatedBy: item.0,
										toItem: prev, attribute: .right,
										multiplier: 1.0, constant: item.1)
			arr.append(c1)
			prev = item.2
		}

		let c3 = NSLayoutConstraint(item: v, attribute: .right,
									relatedBy: relation,
									toItem: views.last!.2, attribute: .right,
									multiplier: 1.0, constant: -offset)
		arr.append(c3)
		v.addConstraints(arr)
		return arr
	}
}

@objc extension NSView {
	@objc public var grab: DSFConstraintsBuilder {
		return DSFConstraintsBuilder(view: self)
	}
}
