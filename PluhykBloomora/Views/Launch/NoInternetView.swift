//
//  NoInternetView.swift
//  PluhykBloomora
//
//  Created on 2026-01-27.
//

import SwiftUI

struct NoInternetView: View {
    var onRetry: () -> Void
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "wifi.slash")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                
                VStack(spacing: 12) {
                    Text("No Internet Connection")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Please check your connection and try again")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#2490ad"))
                    .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

struct NoInternetView_Previews: PreviewProvider {
    static var previews: some View {
        NoInternetView {
            print("Retry tapped")
        }
    }
}
