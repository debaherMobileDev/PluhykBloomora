//
//  WebViewWrapper.swift
//  PluhykBloomora
//
//  Created on 2026-02-01.
//

import SwiftUI
import WebKit

// MARK: - Improved WebView with all required features

struct ImprovedWebView: UIViewRepresentable {
    let url: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let preferences = WKPreferences()
        
        // JavaScript поддержка
        let contentController = WKUserContentController()
        configuration.userContentController = contentController
        
        // Inline video autoplay
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Protected Media ID - автоматическое разрешение
        if #available(iOS 15.0, *) {
            configuration.upgradeKnownHostsToHTTPS = false
        }
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Поддержка back navigation
        webView.allowsBackForwardNavigationGestures = true
        
        // Safe Area
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // Cookie persistence
        let dataStore = WKWebsiteDataStore.default()
        configuration.websiteDataStore = dataStore
        
        // Custom UserAgent - нативный без wv
        let systemVersion = UIDevice.current.systemVersion
        let model = UIDevice.current.model
        let customUA = "Mozilla/5.0 (\(model); CPU \(model) OS \(systemVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(systemVersion) Mobile/15E148 Safari/604.1"
        webView.customUserAgent = customUA
        
        // Keyboard handling
        setupKeyboardHandling(for: webView)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardHandling(for webView: WKWebView) {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            
            let keyboardHeight = keyboardFrame.height
            webView.scrollView.contentInset.bottom = keyboardHeight
            webView.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            webView.scrollView.contentInset.bottom = 0
            webView.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: ImprovedWebView
        var lastRedirectURL: URL?
        
        init(_ parent: ImprovedWebView) {
            self.parent = parent
        }
        
        // MARK: - Navigation Delegate
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                lastRedirectURL = url
                
                // Обработка deep links (tel:, mailto:, etc)
                if !url.scheme!.hasPrefix("http") {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
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
                    return
                }
            }
            
            print("❌ WebView: Navigation error: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView: Page loaded: \(webView.url?.absoluteString ?? "unknown")")
        }
        
        // MARK: - UI Delegate (для загрузки файлов)
        
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView, 
                    requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                    initiatedByFrame frame: WKFrameInfo,
                    type: WKMediaCaptureType,
                    decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            // Автоматически разрешаем Protected Media ID
            decisionHandler(.grant)
        }
    }
}


// MARK: - Preview

struct ImprovedWebView_Previews: PreviewProvider {
    static var previews: some View {
        ImprovedWebView(url: "https://test-web.syndi-test.net/")
    }
}
