//
//  FirebaseAppDelegate.swift
//  PluhykBloomora
//
//  Created on 2026-01-30.
//

import UIKit
import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class FirebaseAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Инициализация Firebase
        FirebaseApp.configure()
        print("✅ Firebase: Configured")
        
        // Настройка UNUserNotificationCenter
        UNUserNotificationCenter.current().delegate = self
        
        // Инициализация сервисов
        FirebaseManager.shared.configure()
        AppsFlyerManager.shared.configure()
        
        return true
    }
    
    // MARK: - Remote Notifications
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ APNS: Device token registered")
        
        // Передаем токен в Firebase Messaging
        FirebaseManager.shared.setAPNSToken(deviceToken)
        
        // Можно также передать в AppsFlyer если нужно
        // AppsFlyerLib.shared().registerUninstall(deviceToken)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ APNS: Failed to register: \(error.localizedDescription)")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Уведомление пришло когда приложение на переднем плане
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("📬 Notification received in foreground: \(userInfo)")
        
        // Обрабатываем уведомление
        FirebaseManager.shared.handleNotification(userInfo: userInfo)
        
        // Показываем уведомление даже когда приложение открыто
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Пользователь нажал на уведомление
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("📬 Notification tapped: \(userInfo)")
        
        // Обрабатываем нажатие на уведомление
        FirebaseManager.shared.handleNotification(userInfo: userInfo)
        
        completionHandler()
    }
}
