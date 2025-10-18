///
/// Color+Theme.swift
/// TodoBar
///
/// 主题色彩扩展
///

import SwiftUI

extension Color {
    // MARK: - Primary Colors
    
    static var themePrimary: Color {
        Color(hex: "#0066FF")
    }
    
    static var themeSecondary: Color {
        Color(hex: "#5856D6")
    }
    
    static var themeAccent: Color {
        Color(hex: "#FF9500")
    }
    
    // MARK: - Background Colors
    
    static var themeBackground: Color {
        Color(nsColor: .controlBackgroundColor)
    }
    
    static var themeCardBackground: Color {
        Color(nsColor: .windowBackgroundColor)
    }
    
    // MARK: - Text Colors
    
    static var themePrimaryText: Color {
        Color(nsColor: .labelColor)
    }
    
    static var themeSecondaryText: Color {
        Color(nsColor: .secondaryLabelColor)
    }
    
    // MARK: - Status Colors
    
    static var themeSuccess: Color {
        Color(hex: "#34C759")
    }
    
    static var themeWarning: Color {
        Color(hex: "#FF9500")
    }
    
    static var themeError: Color {
        Color(hex: "#FF3B30")
    }
    
    // MARK: - Priority Colors
    
    static var priorityLow: Color {
        Color(hex: "#34C759")
    }
    
    static var priorityMedium: Color {
        Color(hex: "#FF9500")
    }
    
    static var priorityHigh: Color {
        Color(hex: "#FF3B30")
    }
    
    // MARK: - Helper
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

