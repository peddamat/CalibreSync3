//
//  Triangle.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/15/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct Triangle: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

    return path
  }
}

struct Triangle_Previews: PreviewProvider {
  static var previews: some View {
    Triangle()
      .fill(Color.red)
      .frame(width: 300, height: 300)
  }
}
