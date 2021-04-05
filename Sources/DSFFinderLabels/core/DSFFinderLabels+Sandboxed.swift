//
//  DSFFinderLabels+Sandboxed.swift
//  DSFFinderLabels
//
//  Created by Darren Ford on 6/4/21.
//  Copyright © 2021 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2021 Darren Ford
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

@available(OSX 10.11, *)
public extension DSFFinderLabels {
	/// Returns ALL the tags defined in the system
	///
	/// Can only be called from a non-sandboxed environment
	static func allTags() throws -> [(String, DSFFinderLabels.ColorIndex)] {
		let vals = try self.allTagLabels()

		let colorLabels = DSFFinderLabels.FinderColors.allColorLabels

		var tags = [(String, DSFFinderLabels.ColorIndex)]()
		for tag in vals {
			if !colorLabels.contains(tag.0) {
				let ci = ColorIndex(rawValue: tag.1) ?? .none
				tags.append((tag.0, ci))
			}
		}

		// Map the tags and colors to the output
		return tags
	}
}

private extension DSFFinderLabels {
	private static func throwIfSandboxed() throws {
		let bundleURL = Bundle.main.bundleURL
		var staticCode: SecStaticCode?
		let kSecCSDefaultFlags: SecCSFlags = SecCSFlags(rawValue: SecCSFlags.RawValue(0))

		if SecStaticCodeCreateWithPath(bundleURL as CFURL, kSecCSDefaultFlags, &staticCode) == errSecSuccess {
			if SecStaticCodeCheckValidityWithErrors(staticCode!, SecCSFlags(rawValue: kSecCSBasicValidateOnly), nil, nil) == errSecSuccess {
				let appSandbox = "entitlement[\"com.apple.security.app-sandbox\"] exists"
				var sandboxRequirement: SecRequirement?

				if SecRequirementCreateWithString(appSandbox as CFString, kSecCSDefaultFlags, &sandboxRequirement) == errSecSuccess {
					let codeCheckResult: OSStatus = SecStaticCodeCheckValidityWithErrors(staticCode!, SecCSFlags(rawValue: kSecCSBasicValidateOnly), sandboxRequirement, nil)
					if codeCheckResult == errSecSuccess {
						throw DSFFinderLabelsError.sandboxed
					}
				}
			}
		}
		return
	}

	@available(OSX 10.11, *)
	private static func allTagLabels() throws -> [(String, Int)] {
		/// Cannot be called from a sandboxed environment
		try self.throwIfSandboxed()

		let libPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
		guard libPath.count > 0 else {
			return []
		}

		let ll = libPath[0]
		let url = URL(fileURLWithPath: "SyncedPreferences/com.apple.finder.plist",
						  relativeTo: URL(fileURLWithPath: ll))

		let keyPath = "values.FinderTagDict.value.FinderTags"
		if let d = try? Data(contentsOf: url) {
			if let plist = try? PropertyListSerialization.propertyList(from: d, options: [], format: nil),
				let pdict = plist as? NSDictionary,
				let ftags = pdict.value(forKeyPath: keyPath) as? [[AnyHashable: Any]] {
				return ftags.compactMap {
					if let name = $0["n"] as? String {
						let index = $0["l"] as? Int ?? -1
						return (name, index)
					}
					return nil
				}
			}
		}
		return []
	}
}
