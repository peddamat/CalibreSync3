//
//  PageSwipeView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/8/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct PageSwipeView: View {
  var body: some View {
    ZStack {
      Page2()
      Page1()
        .background(Color.red)
        .offset(x: 0, y: 10)

    }

  }
}

struct Page1: View {
  var body: some View {
    ZStack {
      Text("Page 1")
    }
  }
}

struct Page2: View {
  var body: some View {
    ZStack {
      Text("Page 2")
    }
    .background(Color.blue)
  }
}

struct PageSwipeView_Previews: PreviewProvider {
  static var previews: some View {
    PageSwipeView()
  }
}
