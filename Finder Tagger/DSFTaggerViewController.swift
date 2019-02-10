//
//  DSFTaggerViewController.swift
//  Finder Tagger
//
//  Created by Darren Ford on 9/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

import DSFFinderLabels


class CollectionViewLeftFlowLayout: NSCollectionViewFlowLayout
{
	override func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes]
	{
		let defaultAttributes = super.layoutAttributesForElements(in: rect)

		if defaultAttributes.isEmpty {
			return defaultAttributes
		}

		var leftAlignedAttributes = [NSCollectionViewLayoutAttributes]()

		var xCursor = self.sectionInset.left                            // left margin
		var lastYPosition = defaultAttributes[0].frame.origin.y         // if/when there is a new row, we want to start at left margin
		var lastItemHeight = defaultAttributes[0].frame.size.height

		for attributes in defaultAttributes
		{
			// copy() Needed to avoid warning from CollectionView that cached values are mismatched
			guard let newAttributes = attributes.copy() as? NSCollectionViewLayoutAttributes else {
				continue;
			}

			if newAttributes.frame.origin.y > (lastYPosition + lastItemHeight)
			{
				// We have started a new row
				xCursor = self.sectionInset.left
				lastYPosition = newAttributes.frame.origin.y
			}

			newAttributes.frame.origin.x = xCursor

			xCursor += newAttributes.frame.size.width + minimumInteritemSpacing
			lastItemHeight = newAttributes.frame.size.height

			leftAlignedAttributes.append(newAttributes)
		}
		return leftAlignedAttributes
	}
}

class LeftFlowLayout: NSCollectionViewFlowLayout {

	override func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes] {


		let defaultAttributes = super.layoutAttributesForElements(in: rect)

		if defaultAttributes.isEmpty {
			// we rely on 0th element being present,
			// bail if missing (when there's no work to do anyway)
			return defaultAttributes
		}

		var leftAlignedAttributes = [NSCollectionViewLayoutAttributes]()

		var xCursor = self.sectionInset.left // left margin

		// if/when there is a new row, we want to start at left margin
		// the default FlowLayout will sometimes centre items,
		// i.e. new rows do not always start at the left edge

		var lastYPosition = defaultAttributes[0].frame.origin.y

		for attributes in defaultAttributes {
			if attributes.frame.origin.y > lastYPosition {
				// we have changed line
				xCursor = self.sectionInset.left
				lastYPosition = attributes.frame.origin.y
			}

			attributes.frame.origin.x = xCursor
			// by using the minimumInterimitemSpacing we no we'll never go
			// beyond the right margin, so no further checks are required
			xCursor += attributes.frame.size.width + minimumInteritemSpacing

			leftAlignedAttributes.append(attributes)
		}
		return leftAlignedAttributes
	}
}





class DSFTaggerViewController: NSCollectionViewItem {

	var taggerLabel: NSTextField?
	var colorSelector: DSFFinderColorGridView?
	var tagSelector: NSTokenField?

	var activeSearch: DSFFinderLabels.Search?

	override func loadView()
	{
		self.view = NSView()
		self.view.translatesAutoresizingMaskIntoConstraints = false

		let colorSelector = DSFFinderColorGridView()
		self.colorSelector = colorSelector

		colorSelector.setContentCompressionResistancePriority(.required, for: .vertical)
		colorSelector.setContentHuggingPriority(.defaultLow, for: .vertical)
		colorSelector.translatesAutoresizingMaskIntoConstraints = false

		let tagSelector = NSTokenField()
		self.tagSelector = tagSelector
		tagSelector.translatesAutoresizingMaskIntoConstraints = false

		let taggerLabel = NSTextField()
		taggerLabel.isEditable = true
		taggerLabel.translatesAutoresizingMaskIntoConstraints = false
		taggerLabel.setContentHuggingPriority(.defaultLow, for: .vertical)

		self.view.addSubview(taggerLabel)
		self.view.addSubview(colorSelector)
		self.view.addSubview(tagSelector)

		self.view.addConstraints(
			NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==0)-[taggerLabel]-(==8)-[colors]-(==8)-[tags]-(>=20)-|",
										   options: [],
										   metrics: nil,
										   views: ["colors": colorSelector, "tags": tagSelector, "taggerLabel": taggerLabel]))

		self.view.addConstraints(
			NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==0)-[colors]-(==0)-|",
										   options: [],
										   metrics: nil,
										   views: ["colors": colorSelector, "tags": tagSelector]))

		self.view.addConstraint(
			NSLayoutConstraint(item: taggerLabel, attribute: .leading,
							   relatedBy: .equal,
							   toItem: colorSelector, attribute: .leading,
							   multiplier: 1, constant: 0))
		self.view.addConstraint(
			NSLayoutConstraint(item: taggerLabel, attribute: .trailing,
							   relatedBy: .equal,
							   toItem: colorSelector, attribute: .trailing,
							   multiplier: 1, constant: 0))

		//		self.view.addConstraints(
		//			NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==0)-[taggerLabel]-(>=0)-|",
		//										   options: [],
		//										   metrics: nil,
		//										   views: ["taggerLabel": taggerLabel]))

		self.view.addConstraint(
			NSLayoutConstraint(item: tagSelector, attribute: .leading,
							   relatedBy: .equal,
							   toItem: colorSelector, attribute: .leading,
							   multiplier: 1, constant: 0))
		self.view.addConstraint(
			NSLayoutConstraint(item: tagSelector, attribute: .trailing,
							   relatedBy: .equal,
							   toItem: colorSelector, attribute: .trailing,
							   multiplier: 1, constant: 0))


		//		self.view.addConstraints(
		//			NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==0)-[tagSelector]-(>=0)-|",
		//										   options: [],
		//										   metrics: nil,
		//										   views: ["tagSelector": tagSelector] ))

		tagSelector.addConstraint(
			NSLayoutConstraint(item: tagSelector, attribute: .height,
							   relatedBy: .equal,
							   toItem: nil, attribute: .notAnAttribute,
							   multiplier: 1, constant: 50))

	}

	func search()
	{
		if let colors = self.colorSelector?.selectedColors
		{
			let tags = self.taggerLabel?.objectValue as? [String] ?? []
			
			let labels = DSFFinderLabels()
			labels.colors = Set(colors)
			labels.tags = Set(tags)

			self.activeSearch = labels.findAllMatching { (urls) in
				print(urls)
			}
		}
	}
}
