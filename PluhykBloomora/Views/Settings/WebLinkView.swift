//
//  WebLinkView.swift
//  PluhykBloomora
//
//  Created on 2026-01-27.
//

import SwiftUI
import WebKit

struct WebLinkView: View {
    let url: String
    let title: String
    
    var body: some View {
        SimpleWebView(url: url)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct SimpleWebView: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

struct WebLinkView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WebLinkView(url: "https://pluhykbloomora.com/privacy-policy.html", title: "Privacy Policy")
        }
    }
}
