//
//  ConfigService.swift
//  PluhykBloomora
//
//  Created on 2026-01-27.
//

import Foundation

class ConfigService {
    static let shared = ConfigService()
    
    private let configURL = "https://pluhykbloomora.com/config.php"
    
    private init() {}
    
    // MARK: - Main Request
    
    func fetchConfig(
        conversionData: [String: Any],
        deepLinkData: [String: Any]?,
        afId: String,
        bundleId: String,
        storeId: String,
        locale: String,
        pushToken: String?,
        firebaseProjectId: String?,
        completion: @escaping (Result<ConfigResponse, Error>) -> Void
    ) {
        // Объединяем все параметры
        var parameters: [String: Any] = conversionData
        
        // Добавляем deep link data если есть
        if let deepLinkData = deepLinkData {
            // Deep link данные добавляем, но не перезаписываем существующие ключи
            for (key, value) in deepLinkData {
                if parameters[key] == nil {
                    parameters[key] = value
                }
            }
        }
        
        // Добавляем обязательные поля
        parameters["af_id"] = afId
        parameters["bundle_id"] = bundleId
        parameters["os"] = "iOS"
        parameters["store_id"] = storeId
        parameters["locale"] = locale
        
        // Добавляем опциональные поля
        if let pushToken = pushToken {
            parameters["push_token"] = pushToken
        }
        
        if let firebaseProjectId = firebaseProjectId {
            parameters["firebase_project_id"] = firebaseProjectId
        }
        
        // Выполняем запрос
        performRequest(with: parameters, completion: completion)
    }
    
    // MARK: - Network Request
    
    private func performRequest(with parameters: [String: Any], completion: @escaping (Result<ConfigResponse, Error>) -> Void) {
        guard let url = URL(string: configURL) else {
            completion(.failure(NSError(domain: "ConfigService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "ConfigService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Логируем ответ для отладки
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Config Response: \(jsonString)")
            }
            
            do {
                let response = try JSONDecoder().decode(ConfigResponse.self, from: data)
                completion(.success(response))
            } catch {
                // Если не удалось декодировать, пробуем обработать как ошибку
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Helper Methods
    
    func getCurrentLocale() -> String {
        let locale = Locale.current
        if let languageCode = locale.languageCode {
            return languageCode
        }
        return "en"
    }
    
    func getBundleId() -> String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    func getStoreId() -> String {
        return "id6758214455"
    }
}
