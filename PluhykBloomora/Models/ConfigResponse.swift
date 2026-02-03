//
//  ConfigResponse.swift
//  PluhykBloomora
//
//  Created on 2026-01-27.
//

import Foundation

struct ConfigResponse: Codable {
    let ok: Bool
    let url: String?
    let expires: TimeInterval?
    let message: String?
    
    var isValid: Bool {
        return ok && url != nil
    }
}

struct SavedWebViewData: Codable {
    let url: String
    let expires: TimeInterval
    
    var isExpired: Bool {
        return Date().timeIntervalSince1970 > expires
    }
}
