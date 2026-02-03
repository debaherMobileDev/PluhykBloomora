//
//  AppModeManager.swift
//  PluhykBloomora
//
//  Created on 2026-01-27.
//

import Foundation

class AppModeManager {
    static let shared = AppModeManager()
    
    private let userDefaults = UserDefaults.standard
    private let appModeKey = "pluhyk.appMode"
    private let webViewDataKey = "pluhyk.webViewData"
    private let pushPermissionTimestampKey = "pluhyk.pushPermissionTimestamp"
    
    private init() {}
    
    // MARK: - App Mode
    
    var currentMode: AppMode {
        get {
            guard let rawValue = userDefaults.string(forKey: appModeKey),
                  let mode = AppMode(rawValue: rawValue) else {
                return .notDetermined
            }
            return mode
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: appModeKey)
        }
    }
    
    func isFirstLaunch() -> Bool {
        return currentMode == .notDetermined
    }
    
    // MARK: - WebView Data
    
    func saveWebViewData(url: String, expires: TimeInterval) {
        let data = SavedWebViewData(url: url, expires: expires)
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: webViewDataKey)
        }
    }
    
    func getWebViewData() -> SavedWebViewData? {
        guard let data = userDefaults.data(forKey: webViewDataKey),
              let decoded = try? JSONDecoder().decode(SavedWebViewData.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    func clearWebViewData() {
        userDefaults.removeObject(forKey: webViewDataKey)
    }
    
    // MARK: - Push Permission
    
    func shouldShowPushPermission() -> Bool {
        guard let timestamp = userDefaults.object(forKey: pushPermissionTimestampKey) as? TimeInterval else {
            return true // Первый раз
        }
        
        let threeDaysInSeconds: TimeInterval = 259200 // 3 дня
        let now = Date().timeIntervalSince1970
        
        return (now - timestamp) >= threeDaysInSeconds
    }
    
    func savePushPermissionDeclined() {
        let now = Date().timeIntervalSince1970
        userDefaults.set(now, forKey: pushPermissionTimestampKey)
    }
    
    func clearPushPermissionTimestamp() {
        userDefaults.removeObject(forKey: pushPermissionTimestampKey)
    }
    
    // MARK: - Reset All
    
    func resetAll() {
        userDefaults.removeObject(forKey: appModeKey)
        userDefaults.removeObject(forKey: webViewDataKey)
        userDefaults.removeObject(forKey: pushPermissionTimestampKey)
    }
}
