<p align="center">
    <img src="ouroboros.png" width="33%" style="max-width:100%;">
</p>

# VIPER

<p align="center">
    <a href="https://github.com/apple/swift"><img src="https://img.shields.io/badge/swift-5.1-f16d39"></a>
    <img src="https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20tvos%20-lightgrey">
    <a href="https://github.com/thomverbeek/VIPER/releases"><img src="https://img.shields.io/github/v/tag/thomverbeek/VIPER?label=release"></a>
</p>

A simple framework of VIPER components to construct modules.

VIPER is an iOS architecture pattern. Originally coined by developers of [Mutual Mobile](https://mutualmobile.com/resources/architecting-ios-apps-viper) and popularised by [objc.io](https://www.objc.io/issues/13-architecture/viper/), it's an implementation of the [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) by Robert C. Martin. 

## Xcode

In your project or workspace, choose <code>File ▸ Swift Packages ▸ Add Package Dependency…</code> to add VIPER as a package dependency.  

## Swift Package Manager

Add the following to your `Package.swift`'s `dependencies:` array:

```swift
.package(url: "git@github.com:thomverbeek/VIPER.git", from: "0.3.0"),
```

## VIPER command line tool

This package comes bundled with `viper-tools`, a command line utility. You can use this to
generate new VIPER modules. Simply call `swift run viper-tools` from the Swift package
directory to generate a named VIPER module for your intended platform.
