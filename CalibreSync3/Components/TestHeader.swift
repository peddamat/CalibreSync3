//
//  TestHeader.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/15/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct TestHeader: View {
  var offset: CGPoint
  @Binding var loading: Bool

  var body: some View {
    Text("\(offset.x)")
  }
}

//struct TestHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        TestHeader()
//    }
//}
