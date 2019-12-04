//
//  RefreshableScrollView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/4/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

// Authoer: The SwiftUI Lab
// Full article: https://swiftui-lab.com/scrollview-pull-to-refresh/

import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @State private var previousScrollOffset: CGFloat = 0
    @State private var previousBottomScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var bottomScrollOffset: CGFloat = 0
    @State private var frozen: Bool = false
    @State private var rotation: Angle = .degrees(0)
    @EnvironmentObject var settingStore: SettingStore

    
    var topThreshold: CGFloat = 80
    var bottomThreshold: CGFloat = 530
    @Binding var refreshing: Bool
    @Binding var loadingMore: Bool
    let content: Content

    init(height: CGFloat = 80, refreshing: Binding<Bool>, loadingMore: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.topThreshold = height
        self._refreshing = refreshing
        self._loadingMore = loadingMore
        self.content = content()
    }
    
    var body: some View {
        return VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()
                    
                    VStack {
                        self.content
                        BottomView()
                    }.alignmentGuide(.top, computeValue: { d in (self.refreshing && self.frozen) ? -self.topThreshold : 0.0 })
                    
                    SearchBarView(height: self.topThreshold, loading: self.refreshing, frozen: self.frozen, rotation: self.rotation).environmentObject(settingStore)
                }
            }
            .background(FixedView())
            .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
                self.refreshLogic(values: values)
            }
        }
    }
    
    func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            // Calculate scroll offset
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let bottomBounds = values.first { $0.vType == .bottomView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
            
            self.scrollOffset  = movingBounds.minY - fixedBounds.minY
            self.bottomScrollOffset  = bottomBounds.minY - fixedBounds.minY
//            NSLog("scroll: \(self.bottomScrollOffset)")
            
            self.rotation = self.symbolRotation(self.scrollOffset)
            
            // Crossing the threshold on the way down, we start the refresh process
            if !self.refreshing && (self.scrollOffset > self.topThreshold && self.previousScrollOffset <= self.topThreshold) {
                self.refreshing = true
            }
            
            if !self.loadingMore && (self.bottomScrollOffset < self.bottomThreshold && self.previousBottomScrollOffset >= self.bottomThreshold) {
                self.loadingMore = true
                NSLog("Loading more")
            }
            
            if self.refreshing {
                // Crossing the threshold on the way up, we add a space at the top of the scrollview
                if self.previousScrollOffset > self.topThreshold && self.scrollOffset <= self.topThreshold {
                    self.frozen = true
                }
            } else {
                // remove the space at the top of the scroll view
                self.frozen = false
            }
            
            // Update last scroll offset
            self.previousScrollOffset = self.scrollOffset
            self.previousBottomScrollOffset = self.bottomScrollOffset
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
    
    // This view displays the arrow and activity indicator
    struct SearchBarView: View {
        var height: CGFloat
        var loading: Bool
        var frozen: Bool
        var rotation: Angle
        @EnvironmentObject var settingStore: SettingStore

        
        var body: some View {
            Group {
                if self.loading { // If loading, show the activity control
                    VStack {
                        Spacer()
                        SearchView().environmentObject(self.settingStore)
                        Spacer()
                    }.frame(height: height).fixedSize()
                        .offset(y: -height + (self.loading && self.frozen ? height : 0.0))
                }
            }
        }
    }
    
    // This view is inserted within the ScrollView to enable measuring the scroll offset
    struct MovingView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .movingView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }
    
    struct BottomView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .bottomView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }
    
    // This view is fixed within the ScrollView allowing scroll offset to be measured
    //   in relation to MovingView
    struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))])
            }
        }
    }
}

struct RefreshableKeyTypes {
    enum ViewType: Int {
        case movingView
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
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityRep>) {
        uiView.startAnimating()
    }
}
