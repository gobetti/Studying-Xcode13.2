//
//  Backport.swift
//  Xcode13_2
//
//  Created by Marcelo Gobetti on 16/12/21.
//

import SwiftUI

// https://davedelong.com/blog/2021/10/09/simplifying-backwards-compatibility-in-swift/
public struct Backport<Content> {
    public let content: Content

    public init(_ content: Content) {
        self.content = content
    }
}

extension View {
    var backport: Backport<Self> { Backport(self) }
}

extension Backport where Content: View {
    @available(iOS, introduced: 13.0, deprecated: 14.0, message: "This override is no longer necessary; you should remove `.backport` and use the built-in methods instead.")
    @available(macOS, introduced: 10.15, deprecated: 11.0, message: "This override is no longer necessary; you should remove `Backport.` and use the built-in component instead.")
    @ViewBuilder func navigationTitle<S>(_ title: S) -> some View where S: StringProtocol {
        if #available(iOS 14, macOS 11, *) {
            content.navigationTitle(title)
        } else {
            #if os(iOS)
            content.navigationBarTitle(title)
            #else
            content
            #endif
        }
    }
}

extension Backport where Content == Any {
    @available(iOS, introduced: 13.0, deprecated: 14.0, message: "This override is no longer necessary; you should remove `Backport.` and use the built-in component instead.")
    @available(macOS, introduced: 10.15, deprecated: 11.0, message: "This override is no longer necessary; you should remove `Backport.` and use the built-in component instead.")
    @ViewBuilder static func ProgressView() -> some View {
        if #available(iOS 14, macOS 11, *) {
            SwiftUI.ProgressView()
        } else {
            Text("Loading...")
        }
    }
}
