//
//  DSFFinderTagsField.swift
//  DSFFinderLabels
//
//  Created by Darren Ford on 18/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

open class DSFFinderTagsField: NSTokenField {
	public var finderTags: [String] {
		get {
			return self.objectValue as? [String] ?? []
		}
		set {
			self.objectValue = newValue
		}
	}
}
