Pod::Spec.new do |s|
s.name         = "DSFFinderLabels"
s.version      = "1.0"
s.summary      = "Finder Label support class for Swift and Objective-C"
s.description  = <<-DESC
Finder Label support class for Swift and Objective-C
DESC
s.homepage     = "https://github.com/dagronf/DSFFinderLabels"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Darren Ford" => "dford_au-reg@yahoo.com" }
s.social_media_url   = ""
s.osx.deployment_target = "10.12"
s.source       = { :git => ".git", :tag => s.version.to_s }
s.source_files  = "DSFFinderLabels/core/*.swift", "DSFFinderLabels/ui/*.swift"
s.frameworks  = "Cocoa"
s.swift_version = "5.0"
end
