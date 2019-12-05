//
//  OnboardingView.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/4/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @State private var show_modal: Bool = false
    @EnvironmentObject var settingStore: SettingStore
    
    let bgColor = Color(red: 244/255.0, green: 236/255.0, blue: 230/255.0)
    
    var body: some View {
        
        ZStack {
            Color.init(red: 244/255.0, green: 236/255.0, blue: 230/255.0)
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing:10) {
                    Text("Welcome to CalibreSync")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.black)
                    
                    Spacer()
                }
                
                Text("To get started, we'll need to connect to your Calibre Library.")
                
                Button(action: {
                    self.show_modal = true
                }) {
                    Text("Select Calibre Library Location")
                }
                                
                Text("Great!  Now we're going to download a local copy of your database.  This may take a few minutes.")

                SimpleProgressBar(circleProgress: .constant(0.2), width: 200, height: 10, progressColor: .blue, staticColor: .gray)

                Text("Awesome, we're ready to go.  Click \"Next\" to get started.")
                    
                Text("If you ever need to change your Calibre Library location, you can do so from the Setting menu.")
                
                Button(action: {
                    self.show_modal = true
                }) {
                    Text("Next")
                }
                
                Spacer()
            }
            .padding(10)
            
        }.sheet(isPresented: self.$show_modal) {
            DirectoryPickerView(callback: self.settingStore.saveCalibrePath)
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

//struct SimpleProgresBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SimpleProgressBar(circleProgress: .constant(0.2), width: 200, height: 10, progressColor: .blue, staticColor: .gray)
//    }
//}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
