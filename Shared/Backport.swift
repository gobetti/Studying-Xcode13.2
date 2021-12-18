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
            #if os(macOS)
            content
            #else
            content.navigationBarTitle(title)
            #endif
        }
    }
}

extension Backport where Content == Any {
    @available(iOS, introduced: 13.0, deprecated: 15.0, message: "This override is no longer necessary; you should remove `Backport.` and use the built-in component instead.")
    @available(macOS, introduced: 10.15, deprecated: 12.0, message: "This override is no longer necessary; you should remove `Backport.` and use the built-in component instead.")
    @ViewBuilder static func AsyncImage<I: View, P: View>(url: URL?, @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) -> some View {
        if #available(iOS 15, macOS 12, *) {
            SwiftUI.AsyncImage(url: url, content: content, placeholder: placeholder)
        } else {
            BackportAsyncImage(url: url, content: content, placeholder: placeholder)
        }
    }

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

/// A quick version of AsyncImage that works before iOS 15/macOS 12, not optimized at all, I just wanted to have a feeling of how hard it would be :)
private struct BackportAsyncImage<I: View, P: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> I
    @ViewBuilder let placeholder: () -> P
    #if os(macOS)
    @State private var image: NSImage?
    #else
    @State private var image: UIImage?
    #endif

    var body: some View {
        Group {
            if let image = image {
                #if os(macOS)
                content(Image(nsImage: image))
                #else
                content(Image(uiImage: image))
                #endif
            } else {
                placeholder()
            }
        }.onAppear {
            guard let url = url else { return }
            Task {
                let (data, _) = try await URLSession.shared.backport.data(from: url)
                image = .init(data: data)
            }
        }
    }
}
