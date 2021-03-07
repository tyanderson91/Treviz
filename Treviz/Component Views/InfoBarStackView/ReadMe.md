# InfoBarStackView

## Description

Demonstrates how to use NSStackView, to show how to stack arbitrary views together.
Each view in the stack is contained within its own NSViewController which can be hidden or shown independently.  It also supports NSWindowRestoration protocol so the stack view window’s state can be restored on relaunch, along with the state of all its child view controllers.

This sample shows two different variations of the header view for each stack item: 1) triangle disclosure based, 2) non-triangle disclosure based.

We conditionally decide what flavor of header to use by "DisclosureTriangleAppearance" compilation flag, which is defined in “Active Compilation Conditions” Build Settings (for passing conditional compilation flags to the Swift compiler).
If you want to use the non-triangle disclosure version, remove that compilation flag.

## Requirements

### Build Requirements

macOS 10.12 SDK or later.

### Runtime Requirements

macOS 10.11 or later.


Copyright (C) 2013-2017 Apple Inc. All rights reserved.
