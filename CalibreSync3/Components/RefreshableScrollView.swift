//
//  RefreshableScrollView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/8/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct RefreshableScrollView<Content: View>: View {
  @ObservedObject var store = Store.shared

  @State private var prevTopScrollOffset: CGFloat = 0
  @State private var topScrollOffset: CGFloat = 0
  @State private var prevBotScrollOffset: CGFloat = 0
  @State private var botScrollOffset: CGFloat = 0
  @State private var frozen: Bool = false
  @State private var rotation: Angle = .degrees(0)

  var topThreshold: CGFloat = 80
  var botThreshold: CGFloat = 570
  @Binding var refreshing: Bool
  @Binding var loading: Bool
  let content: Content

  init(
    height: CGFloat = 80, refreshing: Binding<Bool>, loading: Binding<Bool>,
    @ViewBuilder content: () -> Content
  ) {
    self.topThreshold = height
    self._refreshing = refreshing
    self._loading = loading
    self.content = content()
  }

  var body: some View {
    return VStack {
      ScrollView {
        ZStack(alignment: .top) {
          TopView()

          VStack {
            SearchView()
              .padding(.top, 10)
            self.content
            BottomView()
          }.alignmentGuide(
            .top, computeValue: { d in (self.refreshing && self.frozen) ? -self.topThreshold : 0.0 }
          )

          SymbolView(
            height: self.topThreshold, loading: self.refreshing, frozen: self.frozen,
            rotation: self.rotation)
        }
      }
      .background(FixedView())
      .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
        self.refreshLogic(values: values)
      }
    }
  }

  func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
    //        DispatchQueue.main.async {
    DispatchQueue.global(qos: .userInteractive).async {
      // Calculate scroll offset
      let topBounds = values.first { $0.vType == .topView }?.bounds ?? .zero
      let bottomBounds = values.first { $0.vType == .bottomView }?.bounds ?? .zero
      let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero

      self.topScrollOffset = topBounds.minY - fixedBounds.minY
      self.botScrollOffset = bottomBounds.minY - fixedBounds.minY

      self.rotation = self.symbolRotation(self.topScrollOffset)

      // Crossing the threshold on the way down, we start the refresh process
      if !self.refreshing
        && (self.topScrollOffset > self.topThreshold
          && self.prevTopScrollOffset <= self.topThreshold)
      {
        DispatchQueue.main.async {
          self.refreshing = true
        }
      }

      if !self.loading
        && (self.botScrollOffset < self.botThreshold
          && self.prevBotScrollOffset >= self.botThreshold)
      {
        DispatchQueue.main.async {
          self.loading = true
          //                self.store.loadingMore = true
          NSLog("Loading more")
        }
      }

      if self.refreshing {
        // Crossing the threshold on the way up, we add a space at the top of the scrollview
        if self.prevTopScrollOffset > self.topThreshold && self.topScrollOffset <= self.topThreshold
        {
          self.frozen = true

        }
      } else {
        // remove the sapce at the top of the scroll view
        self.frozen = false
      }

      // Update last scroll offset
      self.prevTopScrollOffset = self.topScrollOffset
      self.prevBotScrollOffset = self.botScrollOffset
    }
  }

  func symbolRotation(_ scrollOffset: CGFloat) -> Angle {

    // We will begin rotation, only after we have passed
    // 60% of the way of reaching the threshold.
    if scrollOffset < self.topThreshold * 0.60 {
      return .degrees(0)
    } else {
      // Calculate rotation, based on the amount of scroll offset
      let h = Double(self.topThreshold)
      let d = Double(scrollOffset)
      let v = max(min(d - (h * 0.6), h * 0.4), 0)
      return .degrees(180 * v / (h * 0.4))
    }
  }

  struct SymbolView: View {
    var height: CGFloat
    var loading: Bool
    var frozen: Bool
    var rotation: Angle

    var body: some View {
      Group {
        if self.loading {  // If loading, show the activity control
          VStack {
            Spacer()
            ActivityRep()
            Spacer()
          }.frame(height: height).fixedSize()
            .offset(y: -height + (self.loading && self.frozen ? height : 0.0))
        } else {
          Image(systemName: "arrow.down")  // If not loading, show the arrow
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: height * 0.25, height: height * 0.25).fixedSize()
            .padding(height * 0.375)
            .rotationEffect(rotation)
            .offset(y: -height + (loading && frozen ? +height : 0.0))
        }
      }
    }
  }

  struct TopView: View {
    var body: some View {
      GeometryReader { proxy in
        Color.clear.preference(
          key: RefreshableKeyTypes.PrefKey.self,
          value: [RefreshableKeyTypes.PrefData(vType: .topView, bounds: proxy.frame(in: .global))])
      }.frame(height: 0)
    }
  }

  struct BottomView: View {
    var body: some View {
      GeometryReader { proxy in
        Color.clear.preference(
          key: RefreshableKeyTypes.PrefKey.self,
          value: [
            RefreshableKeyTypes.PrefData(vType: .bottomView, bounds: proxy.frame(in: .global))
          ])
      }.frame(height: 0)
    }
  }

  struct FixedView: View {
    var body: some View {
      GeometryReader { proxy in
        Color.clear.preference(
          key: RefreshableKeyTypes.PrefKey.self,
          value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))]
        )
      }
    }
  }
}

struct RefreshableKeyTypes {
  enum ViewType: Int {
    case topView
    case fixedView
    case bottomView
  }

  struct PrefData: Equatable {
    let vType: ViewType
    let bounds: CGRect
  }

  struct PrefKey: PreferenceKey {
    static var defaultValue: [PrefData] = []

    static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
      value.append(contentsOf: nextValue())
    }

    typealias Value = [PrefData]
  }
}

struct ActivityRep: UIViewRepresentable {
  func makeUIView(context: UIViewRepresentableContext<ActivityRep>) -> UIActivityIndicatorView {
    return UIActivityIndicatorView()
  }

  func updateUIView(
    _ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityRep>
  ) {
    uiView.startAnimating()
  }
}
