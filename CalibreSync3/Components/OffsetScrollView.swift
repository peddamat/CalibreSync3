//
//  OffsetScrollView.swift
//
//  Created by Zac White on 9/30/19.
//  Copyright © 2019 Zac White. All rights reserved.
//

import SwiftUI

public struct OffsetScrollView<Content>: View where Content: View {

  /// The content of the scroll view.
  public var content: Content

  /// The scrollable axes.
  ///
  /// The default is `.vertical`.
  public var axes: Axis.Set

  /// If true, the scroll view may indicate the scrollable component of
  /// the content offset, in a way suitable for the platform.
  ///
  /// The default is `true`.
  public var showsIndicators: Bool

  /// The initial offset in the global frame, used for calculating the relative offset
  @State private var initialOffset: CGPoint? = nil

  /// The offset of the scrollview updated as the scroll view scrolls
  @Binding public var offset: CGPoint

  @State private var loading: Bool = false

  public init(
    _ axes: Axis.Set = .vertical, showsIndicators: Bool = true,
    offset: Binding<CGPoint> = .constant(.zero), @ViewBuilder content: () -> Content
  ) {
    self.axes = axes
    self.showsIndicators = showsIndicators
    self._offset = offset
    self.content = content()
  }

  /// Declares the content and behavior of this view.
  public var body: some View {
    ScrollView(axes, showsIndicators: showsIndicators) {
      VStack(alignment: .leading, spacing: 0) {
        GeometryReader { geometry in
          Run {
            let globalOrigin = geometry.frame(in: .global).origin
            self.initialOffset = self.initialOffset ?? globalOrigin
            let initialOffset = (self.initialOffset ?? .zero)
            let offset = CGPoint(
              x: globalOrigin.x - initialOffset.x, y: globalOrigin.y - initialOffset.y)
            self.offset = offset
          }
        }.frame(width: 0, height: 0)

        content
      }
    }
  }
}
