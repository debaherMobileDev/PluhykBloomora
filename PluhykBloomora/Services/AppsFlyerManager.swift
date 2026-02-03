//
//  AppsFlyerManager.swift
//  PluhykBloomora
//
//  Created on 2026-01-27.
//

import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport

class AppsFlyerManager: NSObject {
    static let shared = AppsFlyerManager()
    
    private let devKey = "cqTiFvvyhL5a2SNAqqAna3"
    private let appleAppId = "6758214455"
    
    private var conversionDataCallback: (([String: Any]) -> Void)?
    private var deepLinkCallback: (([String: Any]) -> Void)?
    
    private var isConfigured = false
    
    private override init() {
        super.init()
    }
    
    // MARK: - Initialization
    
    func configure() {
        guard !isConfigured else {
            print("⚠️ AppsFlyerManager: Already configured")
            return
        }
        
        print("⚙️ AppsFlyerManager: Configuring with DevKey: \(devKey)")
        
        AppsFlyerLib.shared().appsFlyerDevKey = devKey
        AppsFlyerLib.shared().appleAppID = appleAppId
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
        
        // Включаем дебаг логи (отключить для продакшена)
        AppsFlyerLib.shared().isDebug = true
        
        // Ждем явного запуска
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        isConfigured = true
        print("✅ AppsFlyerManager: Configured")
    }
    
    func start() {
        print("▶️ AppsFlyerManager: Starting SDK")
        
        // Запрашиваем ATT permission
        requestTrackingPermission {
            AppsFlyerLib.shared().start()
            print("✅ AppsFlyerManager: SDK started")
        }
    }
    
    // MARK: - ATT Permission
    
    private func requestTrackingPermission(completion: @escaping () -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("✅ AppsFlyerManager: Tracking authorized")
                case .denied:
                    print("❌ AppsFlyerManager: Tracking denied")
                case .restricted:
                    print("⚠️ AppsFlyerManager: Tracking restricted")
                case .notDetermined:
                    print("❓ AppsFlyerManager: Tracking not determined")
                @unknown default:
                    print("❓ AppsFlyerManager: Unknown tracking status")
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            completion()
        }
    }
    
    // MARK: - Conversion Data
    
    func onConversionData(callback: @escaping ([String: Any]) -> Void) {
        self.conversionDataCallback = callback
        print("📊 AppsFlyerManager: Conversion data callback registered")
    }
    
    func getAppsFlyerId() -> String {
        let afId = AppsFlyerLib.shared().getAppsFlyerUID()
        return afId ?? "unknown-af-id"
    }
    
    // MARK: - Deep Linking
    
    func onDeepLink(callback: @escaping ([String: Any]) -> Void) {
        self.deepLinkCallback = callback
        print("🔗 AppsFlyerManager: Deep link callback registered")
    }
    
    // MARK: - Helper для проверки af_status
    
    func checkAndRetryIfOrganic(
        conversionData: [String: Any],
        completion: @escaping ([String: Any]) -> Void
    ) {
        guard let afStatus = conversionData["af_status"] as? String else {
            print("⚠️ AppsFlyerManager: No af_status found")
            completion(conversionData)
            return
        }
        
        print("🔍 AppsFlyerManager: af_status = \(afStatus)")
        
        if afStatus == "Organic" {
            print("⏱️ AppsFlyerManager: Organic detected, retrying in 5 seconds via API...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.requestConversionDataViaAPI { result in
                    switch result {
                    case .success(let newData):
                        print("✅ AppsFlyerManager: Got updated conversion data via API")
                        completion(newData)
                    case .failure(let error):
                        print("❌ AppsFlyerManager: API request failed: \(error.localizedDescription)")
                        // Возвращаем оригинальные данные
                        completion(conversionData)
                    }
                }
            }
        } else {
            completion(conversionData)
        }
    }
    
    // MARK: - API Request для повторного получения conversion data
    
    private func requestConversionDataViaAPI(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let afId = getAppsFlyerId()
        let urlString = "https://api2.appsflyer.com/inapps/v2/app/ios/\(appleAppId)?devkey=\(devKey)&device_id=\(afId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "AppsFlyerManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "AppsFlyerManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "AppsFlyerManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

// MARK: - AppsFlyerLibDelegate

extension AppsFlyerManager: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("📥 AppsFlyerManager: Conversion data received")
        
        // Конвертируем в [String: Any]
        var data: [String: Any] = [:]
        for (key, value) in conversionInfo {
            if let stringKey = key as? String {
                data[stringKey] = value
            }
        }
        
        conversionDataCallback?(data)
    }
    
    func onConversionDataFail(_ error: Error) {
        print("❌ AppsFlyerManager: Conversion data failed: \(error.localizedDescription)")
        // Возвращаем пустые данные
        conversionDataCallback?([:])
    }
}

// MARK: - DeepLinkDelegate

extension AppsFlyerManager: DeepLinkDelegate {
    func didResolveDeepLink(_ result: DeepLinkResult) {
        print("🔗 AppsFlyerManager: Deep link resolved")
        
        switch result.status {
        case .found:
            guard let deepLinkObj = result.deepLink else {
                print("❌ AppsFlyerManager: Deep link object is nil")
                return
            }
            
            var data: [String: Any] = [:]
            
            // Основные поля
            if let deeplinkValue = deepLinkObj.deeplinkValue {
                data["deep_link_value"] = deeplinkValue
            }
            
            let clickEvent = deepLinkObj.clickEvent
            for (key, value) in clickEvent {
                if let stringKey = key as? String {
                    data[stringKey] = value
                }
            }
            
            deepLinkCallback?(data)
            
        case .notFound:
            print("⚠️ AppsFlyerManager: Deep link not found")
        case .failure:
            print("❌ AppsFlyerManager: Deep link error")
        @unknown default:
            print("❓ AppsFlyerManager: Unknown deep link status")
        }
    }
}
