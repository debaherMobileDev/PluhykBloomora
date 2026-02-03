//
//  WebViewContainer.swift
//  PluhykBloomora
//
//  Created on 2026-01-27.
//

import SwiftUI
import WebKit

struct WebViewContainer: View {
    let url: String
    
    @State private var showPermissionRequest = false
    @State private var permissionGranted = false
    
    private let appModeManager = AppModeManager.shared
    
    var body: some View {
        ZStack {
            if showPermissionRequest && !permissionGranted {
                CustomPermissionView(
                    onGrant: {
                        permissionGranted = true
                        showPermissionRequest = false
                        requestNotificationPermission()
                    },
                    onSkip: {
                        permissionGranted = true
                        showPermissionRequest = false
                        appModeManager.savePushPermissionDeclined()
                    }
                )
            } else {
                ImprovedWebView(url: url)
                    .ignoresSafeArea()
                    .onAppear {
                        checkPermissionRequest()
                    }
            }
        }
    }
    
    private func checkPermissionRequest() {
        if appModeManager.shouldShowPushPermission() {
            showPermissionRequest = true
        } else {
            permissionGranted = true
        }
    }
    
    private func requestNotificationPermission() {
        FirebaseManager.shared.requestPermission { granted in
            print("📬 Push permission granted: \(granted)")
        }
    }
}

// MARK: - WebView

struct WebView: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // Поддержка JavaScript
        configuration.preferences.javaScriptEnabled = true
        
        // Поддержка inline video autoplay
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // Safe Area
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // Замена UserAgent (будет доработана)
        webView.customUserAgent = getCustomUserAgent()
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func getCustomUserAgent() -> String {
        // Базовый UserAgent для iOS
        let systemVersion = UIDevice.current.systemVersion
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(systemVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(systemVersion) Mobile/15E148 Safari/604.1"
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var lastRedirectURL: URL?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                lastRedirectURL = url
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            
            // Обработка ERR_TOO_MANY_REDIRECTS
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorHTTPTooManyRedirects {
                if let url = lastRedirectURL {
                    print("🔄 WebView: Handling too many redirects, continuing with: \(url)")
                    let request = URLRequest(url: url)
                    webView.load(request)
                }
            } else {
                print("❌ WebView: Navigation error: \(error.localizedDescription)")
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView: Page loaded successfully")
        }
    }
}

// MARK: - Custom Permission View

struct CustomPermissionView: View {
    var onGrant: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#fbaa1a"))
                
                VStack(spacing: 15) {
                    Text("Get Exclusive Bonuses!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Enable notifications to receive special offers and bonuses")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: onGrant) {
                        Text("Yes, I Want Bonuses!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#fbaa1a"))
                            .cornerRadius(15)
                    }
                    
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

struct WebViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        WebViewContainer(url: "https://test-web.syndi-test.net/")
    }
}
