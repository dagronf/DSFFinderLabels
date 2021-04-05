# Swift/ObjC Finder Tag/Label/Color class

Class to retrieve and update Finder tags and colors for file URLs.

## Why?

It seems quite difficult to update string and color tags for a particular url so that they appear in the Finder, and can be searched by Spotlight

* The built-in API for colors only lets you assign a single color. The Finder allows you to set multiple colors.
* Colors seem to be internally managed as String labels. For example, if you set a string tag called "Blue" (in English) then the finder item will have the internal "Blue" color set.
* When in other languages (ie. you set up your computer in German), the localized names for the colors are difficult to map

This class (`DSFFinderLabels`) wraps these API calls to make a consistent method for updating Finder tags and colors

## Features

* Load all tags and colors for a url
* Handles localization issues
* Set multiple colors/tags all with a single call
* Simple convenience UI elements for display

## Simple install

### Cocoapods

Add

`pod 'DSFFinderLabels', :git => 'https://github.com/dagronf/DSFFinderLabels'` 
  
to your Podfile

## Simple usage

There are some tests which show the usage as well

### Set tags and colors for some files

#### Swift

```swift
let labels = DSFFinderLabels()

// Set some colors
labels.set([.blue, .green])

// Add a tag
labels.set(["Work Related"])

// And update some files with the new labels
do {
	let url = URL(string: "file:///Users/blah/Desktop/file.txt")!
	let url2 = URL(string: "file:///Users/blah/Desktop/file2.txt")!
	let url3 = URL(string: "file:///Users/blah/Desktop/file3.txt")!

	try labels.update([url, url2, url3])
}
catch {
	print(error)
}
```

#### Objective-C

```objective-c
NSURL* fileUrl = ...
DSFFinderLabels* labels = [fileUrl finderLabels];
NSSet<NSString*>* tags = [labels getTags];
NSSet<NSNumber*>* colorValues = [labels getColorValues];

[labels addColorWithIndex:DSFFinderLabelsColorIndexBlue];

...

NSError* error = nil;
[fileUrl setFinderLabelsWithFinderLabels:labels error:&error];
```


### Add a color and tag to a file

```swift
let url = URL(string: "file:///Users/blah/Desktop/file.txt")!

let labels = url.finderLabels()
labels.insert(.red)         // Add a new color to the existing colors
labels.insert("Completed")  // Add a new tag to the existing tags

// And update the file and some others with the new label(s) and color(s)
try url.setFinderLabels(labels)
```

### Retrieve finder standard colors and their indexes

```swift
let colors = DSFFinderLabels.FinderColors

// colors.colors[0] = { .none, "None", <none color> }
// colors.colors[1] = { .gray, "Gray", <gray color> }
// colors.colors[2] = { .green, "Green", <green color> }
// ...
```

## Demo screenshot

![](https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFFinderLabels/finder-labels.gif?raw=true)

## License

MIT. Use it and abuse it for anything you want, just attribute my work. Let me know if you do use it somewhere, I'd love to hear about it!

```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
