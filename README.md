<p align="center">
    <img src="ouroboros.png" width="33%" style="max-width:100%;">
</p>

# VIPER

![Swift](https://img.shields.io/badge/swift-5.1-f16d39)
![Platforms](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20tvos%20-lightgrey)
[![Releases](https://img.shields.io/github/v/tag/thomverbeek/VIPER?label=release)](https://github.com/thomverbeek/VIPER/releases)

VIPER is a lightweight [software architecture](https://martinfowler.com/architecture/) framework for Swift.

[Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) is a software architecture pattern devised by Robert C. Martin in 2012 that promotes the SOLID principles of software design. The concept of VIPER is an iOS architecture pattern inspired by the Clean Architecture, originally coined by developers of [Mutual Mobile](https://mutualmobile.com/resources/architecting-ios-apps-viper) and popularised by their [objc.io](https://www.objc.io/issues/13-architecture/viper/) article. This framework is a Swift implementation of the aforementioned architecture principles that enables you to build VIPER apps for iOS, macOS and tvOS.

- [Installation](#installation)
    - [Xcode](#xcode)
    - [Swift Package Manager](#swift-package-manager)
- [VIPER Command Line Tools](#viper-command-line-tools)
- [About VIPER](about-viper)
- [Acknowledgements](acknowledgements)

# Installation

> VIPER is only available as a Swift Package.

## Swift Package Manager

Add the following to your `Package.swift`'s `dependencies:` array:

```swift
.package(url: "git@github.com:thomverbeek/VIPER.git", from: "0.3.0"),
```

## Xcode

In your project or workspace, choose <code>File ▸ Swift Packages ▸ Add Package Dependency…</code> to add `https://github.com/thomverbeek/VIPER` as a package dependency.  


# VIPER Command Line Tools

This package comes bundled with `viper-tools`, a command line utility. You can use this to
generate new VIPER modules. Simply call `swift run viper-tools` from the Swift package
directory to generate a named VIPER module for your intended platform.

# About VIPER

VIPER divides application logic into distinct components of responsibility: 

- `View`: UI logic, including any user interaction
- `Interactor`: business logic, akin to application use cases
- `Presenter`: presentation logic, which maps business logic to view logic
- `Entity`: entity logic, maintained by repositories & services
- `Router`: navigation logic

Conceptually, these five components form a collective `Module`, synonymous with a single screen in your iOS application. The lifecycle of each module is visually represented by the `View`, which holds reference to all components. These components communicate with one another in an orchestrated order, and once the `View` dismisses, the lifecycle ends. The resulting code is clear, testable, modular and scalable with large teams.

The VIPER manifesto isn't without its flaws:
- The `Router`'s role wasn't clearly defined, making it difficult to implement. VIPER intended to solve the _Assembler Problem_ by enabling the `Router` to assemble VIPER modules. But this arrangement jeopardises the Single Responsibility Principle as it already takes responsibility for navigation. And speaking of navigation, the `Router`'s task to pass information between VIPER modules was also left in the dark.
- The `Entity` component was likely a catch-all term for "anything else" in the VIPER backronym. It lacked a clear definition, hinting at an entity layer exclusively for the `Interactor` to interact with. In more ethereal terms, simple entities seem to form the basis of message passing between the various layers of the VIPER module. In practice, it's likely that `Entity` encompasses any repositories or services an `Interactor` may engage with. Without clarity on where these repositories or services come from, the VIPER definition needs some form of dependency injection. 
- VIPER stipulates bi-directional data flow between components, without specifying which component holds state. As the iOS landscape makes its transition towards functional reactive programming, it's important to clearly define the source of state and minimise the potential paths through which this data (and semantic errors) can travel.  

There are numerous implementations out in the wild that try to meet these requirements and then some, but they leave a bit more to be desired. VIPER can be difficult to grasp and fully implement as a framework, and the Swift language throws even more hurdles in the mix due to its linguistic quirks and type-safe limitation. Most frameworks out there simply attempt to translate the original Objective-C sample code to Swift, forcing the developer to wire up components manually and force-cast between types. These frustrations ultimately led to the development of this framework to bring VIPER to the masses

## _“Simplicity is the ultimate sophistication”_

This framework leverages a combination of generics, static scopes and functional reactive programming principles to distill VIPER down to a single file of under a hundred lines of code. Check out `VIPER.swift`. 

- [x] It allows the compiler to help guide beginners, yet provides swiss-army flexibility to advancers.
- [x] It fits VIPER components together like lock and key, without needing to force-cast between types.
- [x] It automates concepts like assembly and weak relationships so you don't have to..
- [x] It extracts assembly responsibility from the `Router` and grants it to the `Module`.
- [x] It uses `Entities` to define the dependencies of an `Interactor`, and `Resolver` to provide dependency injection to the `Router` for navigation.
- [x] It designates the `Interactor` as the holder of state, and exchanges the `Presenter` with the `Interactor` in the assembly. This allows a uni-directional data flow from `View` to `Interactor` to `Presenter` to `View`, more closely in line with the Clean Architecture.

All this results in a VIPER architecture implementation that's simple and sophisticated. For that reason, it's simply called "VIPER".

## What is an Ouroboros?

It's a uni-directional viper, as emblazened on the logo.

# Acknowledgements

- [Yan Heere](https://www.instagram.com/tattoos_by_yan/) for swiftly designing the delightful Ouroboros logo in Swift fashion.

- [OneSadCookie](https://github.com/OneSadCookie) for the many lunchtime discussions about VIPER and the Ouroboros moniker. 
