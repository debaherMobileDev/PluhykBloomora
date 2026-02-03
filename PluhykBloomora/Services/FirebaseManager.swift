//
//  FirebaseManager.swift
//  PluhykBloomora
//
//  Created on 2026-01-27.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class FirebaseManager: NSObject {
    static let shared = FirebaseManager()
    
    private var notificationCallback: ((String) -> Void)?
    private var currentToken: String?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Initialization
    
    func configure() {
        print("⚙️ FirebaseManager: Configuring Firebase...")
        // Firebase.configure() вызывается в AppDelegate
        
        // Настраиваем Messaging
        Messaging.messaging().delegate = self
        print("✅ FirebaseManager: Firebase configured")
    }
    
    // MARK: - Push Token
    
    func getPushToken(completion: @escaping (String?) -> Void) {
        // Если токен уже есть, возвращаем его
        if let token = currentToken {
            completion(token)
            return
        }
        
        // Пытаемся получить токен
        Messaging.messaging().token { token, error in
            if let error = error {
                print("❌ FirebaseManager: Error fetching token: \(error.localizedDescription)")
                completion(nil)
            } else if let token = token {
                print("✅ FirebaseManager: FCM token: \(token)")
                self.currentToken = token
                completion(token)
            } else {
                print("⚠️ FirebaseManager: No token available")
                completion(nil)
            }
        }
    }
    
    func getFirebaseProjectId() -> String? {
        // Получаем Project ID из GoogleService-Info.plist
        if let projectId = FirebaseApp.app()?.options.projectID {
            return projectId
        }
        
        // Альтернативно, получаем GCM Sender ID
        if let senderId = FirebaseApp.app()?.options.gcmSenderID {
            return senderId
        }
        
        return nil
    }
    
    // MARK: - Notification Handling
    
    func onNotificationWithURL(callback: @escaping (String) -> Void) {
        self.notificationCallback = callback
        print("📬 FirebaseManager: Notification callback registered")
    }
    
    func handleNotification(userInfo: [AnyHashable: Any]) {
        print("📥 FirebaseManager: Handling notification: \(userInfo)")
        
        // Проверяем наличие URL в data
        if let data = userInfo["data"] as? [String: Any],
           let url = data["url"] as? String {
            print("🔗 FirebaseManager: Found URL in notification: \(url)")
            notificationCallback?(url)
        }
    }
    
    // MARK: - Permission Request
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ FirebaseManager: Permission request failed: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            print(granted ? "✅ FirebaseManager: Notification permission granted" : "❌ FirebaseManager: Notification permission denied")
            
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            completion(granted)
        }
    }
    
    func setAPNSToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
        print("✅ FirebaseManager: APNS token set")
    }
}

// MARK: - MessagingDelegate

extension FirebaseManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("⚠️ FirebaseManager: FCM token is nil")
            return
        }
        
        print("🔄 FirebaseManager: FCM token refreshed: \(fcmToken)")
        self.currentToken = fcmToken
        
        // Здесь можно отправить обновленный токен на сервер
        // Для нашего случая - нужно будет сделать новый запрос к config.php
    }
}
