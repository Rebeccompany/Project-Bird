//
//  SwiftUIView.swift
//  
//
//  Created by Claudia Fiorentino on 29/09/22.
//

import SwiftUI
import HummingBird

struct OnboardingView: View {
    var body: some View {
        NavigationView {
            ZStack {
                TabView {
                    OnboardingPageOneView()
                    OnboardingPageTwoView()
                    OnboardingPageThreeView()
                    OnboardingPageFourView()
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .toolbar {
                Button("Pular") {
                    print("Hello")
                }
                .padding(.trailing)
                .foregroundColor(HBColor.actionColor)
            }

        }
    }
}


struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
