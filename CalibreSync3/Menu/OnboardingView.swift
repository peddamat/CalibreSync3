//
//  OnboardingView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/4/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ZStack {
            Color.init(red: 244/255.0, green: 236/255.0, blue: 230/255.0)
            .edgesIgnoringSafeArea(.all)
            
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)

        }
    }
}

struct SimpleProgressBar : View {
    
    @Binding var circleProgress: CGFloat
    
    var width: CGFloat
    var height: CGFloat
    var progressColor: Color?
    var staticColor: Color?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(self.staticColor ?? .gray)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(self.progressColor ?? .blue)
                    .frame(width: self.circleProgress*geometry.size.width, height: geometry.size.height)
            }
        }
            .frame(width: width, height: height)
    }

}

struct SimpleProgresBar_Previews: PreviewProvider {
    static var previews: some View {
        SimpleProgressBar(circleProgress: .constant(0.2), width: 200, height: 10, progressColor: .blue, staticColor: .gray)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
