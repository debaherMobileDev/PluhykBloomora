//
//  LaunchDecisionView.swift
//  PluhykBloomora
//
//  Created on 2026-01-27.
//

import SwiftUI

enum LaunchState {
    case loading
    case noInternet
    case webView(url: String)
    case wrapper
}

struct LaunchDecisionView: View {
    @State private var launchState: LaunchState = .loading
    @State private var conversionData: [String: Any]?
    @State private var deepLinkData: [String: Any]?
    
    private let appModeManager = AppModeManager.shared
    private let configService = ConfigService.shared
    private let appsFlyerManager = AppsFlyerManager.shared
    private let firebaseManager = FirebaseManager.shared
    
    var body: some View {
        ZStack {
            switch launchState {
            case .loading:
                LoadingView()
                    .onAppear {
                        startLaunchFlow()
                    }
                
            case .noInternet:
                NoInternetView {
                    // Retry
                    launchState = .loading
                    startLaunchFlow()
                }
                
            case .webView(let url):
                WebViewContainer(url: url)
                
            case .wrapper:
                // Текущее приложение (фантик)
                MainView()
            }
        }
    }
    
    // MARK: - Launch Flow
    
    private func startLaunchFlow() {
        print("🚀 LaunchDecisionView: Starting launch flow...")
        
        // Проверяем, это первый запуск или нет
        if !appModeManager.isFirstLaunch() {
            handleSubsequentLaunch()
        } else {
            handleFirstLaunch()
        }
    }
    
    // MARK: - First Launch
    
    private func handleFirstLaunch() {
        print("🆕 LaunchDecisionView: First launch detected")
        
        // ВАЖНО: Регистрируем callbacks ДО start()
        appsFlyerManager.onConversionData { [self] data in
            print("📊 LaunchDecisionView: Received conversion data")
            print("📊 Conversion Data: \(data)")
            
            // Проверяем af_status и делаем повторный запрос если Organic
            appsFlyerManager.checkAndRetryIfOrganic(conversionData: data) { finalData in
                self.conversionData = finalData
                self.requestConfig()
            }
        }
        
        // Регистрируем callback для deep link
        appsFlyerManager.onDeepLink { [self] data in
            print("🔗 LaunchDecisionView: Received deep link data")
            print("🔗 Deep Link Data: \(data)")
            self.deepLinkData = data
        }
        
        // Инициализируем и запускаем AppsFlyer ПОСЛЕ регистрации callbacks
        appsFlyerManager.configure()
        appsFlyerManager.start()
        
        // Даем время на получение данных (таймаут 10 секунд)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if self.conversionData == nil {
                print("⚠️ LaunchDecisionView: Timeout waiting for conversion data")
                // Если данные не получены, пробуем запросить конфиг с пустыми данными
                self.conversionData = [:]
                self.requestConfig()
            }
        }
    }
    
    // MARK: - Subsequent Launch
    
    private func handleSubsequentLaunch() {
        print("🔄 LaunchDecisionView: Subsequent launch")
        
        let currentMode = appModeManager.currentMode
        
        switch currentMode {
        case .webView:
            // Проверяем сохраненную ссылку
            if let savedData = appModeManager.getWebViewData() {
                if savedData.isExpired {
                    print("⏰ LaunchDecisionView: Saved URL expired, requesting new one")
                    // Запрашиваем новую ссылку
                    requestConfigForSubsequentLaunch()
                } else {
                    print("✅ LaunchDecisionView: Using saved URL")
                    launchState = .webView(url: savedData.url)
                }
            } else {
                print("⚠️ LaunchDecisionView: No saved URL, requesting new one")
                requestConfigForSubsequentLaunch()
            }
            
        case .wrapper:
            print("📦 LaunchDecisionView: Launching wrapper mode")
            launchState = .wrapper
            
        case .notDetermined:
            // Не должно происходить, но на всякий случай
            handleFirstLaunch()
        }
    }
    
    // MARK: - Config Request
    
    private func requestConfig() {
        print("🌐 LaunchDecisionView: Requesting config...")
        
        guard let conversionData = conversionData else {
            print("❌ LaunchDecisionView: No conversion data available")
            launchState = .wrapper
            appModeManager.currentMode = .wrapper
            return
        }
        
        let afId = appsFlyerManager.getAppsFlyerId()
        let bundleId = configService.getBundleId()
        let storeId = configService.getStoreId()
        let locale = configService.getCurrentLocale()
        
        // Получаем Firebase данные (опционально)
        firebaseManager.getPushToken { pushToken in
            let firebaseProjectId = firebaseManager.getFirebaseProjectId()
            
            configService.fetchConfig(
                conversionData: conversionData,
                deepLinkData: deepLinkData,
                afId: afId,
                bundleId: bundleId,
                storeId: storeId,
                locale: locale,
                pushToken: pushToken,
                firebaseProjectId: firebaseProjectId
            ) { result in
                DispatchQueue.main.async {
                    handleConfigResponse(result)
                }
            }
        }
    }
    
    private func requestConfigForSubsequentLaunch() {
        // Для последующих запусков пробуем запросить новую ссылку
        // Если не получится, используем сохраненную
        
        let afId = appsFlyerManager.getAppsFlyerId()
        let bundleId = configService.getBundleId()
        let storeId = configService.getStoreId()
        let locale = configService.getCurrentLocale()
        
        firebaseManager.getPushToken { pushToken in
            let firebaseProjectId = firebaseManager.getFirebaseProjectId()
            
            configService.fetchConfig(
                conversionData: [:], // Минимальные данные
                deepLinkData: nil,
                afId: afId,
                bundleId: bundleId,
                storeId: storeId,
                locale: locale,
                pushToken: pushToken,
                firebaseProjectId: firebaseProjectId
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.isValid, let url = response.url, let expires = response.expires {
                            print("✅ LaunchDecisionView: Got new URL")
                            appModeManager.saveWebViewData(url: url, expires: expires)
                            launchState = .webView(url: url)
                        } else {
                            // Используем сохраненную ссылку
                            if let savedData = appModeManager.getWebViewData() {
                                print("⚠️ LaunchDecisionView: Using saved URL as fallback")
                                launchState = .webView(url: savedData.url)
                            } else {
                                print("❌ LaunchDecisionView: No URL available")
                                launchState = .noInternet
                            }
                        }
                    case .failure:
                        // Используем сохраненную ссылку
                        if let savedData = appModeManager.getWebViewData() {
                            print("⚠️ LaunchDecisionView: Using saved URL after error")
                            launchState = .webView(url: savedData.url)
                        } else {
                            print("❌ LaunchDecisionView: No URL available after error")
                            launchState = .noInternet
                        }
                    }
                }
            }
        }
    }
    
    private func handleConfigResponse(_ result: Result<ConfigResponse, Error>) {
        switch result {
        case .success(let response):
            if response.isValid, let url = response.url, let expires = response.expires {
                print("✅ LaunchDecisionView: Config returned WebView mode")
                // Сохраняем данные
                appModeManager.currentMode = .webView
                appModeManager.saveWebViewData(url: url, expires: expires)
                launchState = .webView(url: url)
            } else {
                print("📦 LaunchDecisionView: Config returned Wrapper mode")
                appModeManager.currentMode = .wrapper
                launchState = .wrapper
            }
            
        case .failure(let error):
            print("❌ LaunchDecisionView: Config request failed: \(error.localizedDescription)")
            
            // Проверяем, есть ли интернет
            if isNetworkError(error) {
                launchState = .noInternet
            } else {
                // Другая ошибка - запускаем wrapper
                appModeManager.currentMode = .wrapper
                launchState = .wrapper
            }
        }
    }
    
    // MARK: - Helper
    
    private func isNetworkError(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == NSURLErrorDomain
    }
}

// MARK: - Loading View

struct LoadingView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#2490ad"), Color(hex: "#3c166d")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "star.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                
                Text("Pluhyk Bloomora")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}

struct LaunchDecisionView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchDecisionView()
    }
}
