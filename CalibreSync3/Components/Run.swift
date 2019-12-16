//
//  Run.swift
//
//  Created by Zac White on 9/30/19.
//  Copyright © 2019 Zac White. All rights reserved.
//

import SwiftUI

struct Run: View {
    let block: () -> Void

    var body: some View {
        DispatchQueue.main.async(execute: block)
//        DispatchQueue.global(qos: .userInitiated).async(execute: block)
        return AnyView(EmptyView())
    }
}
