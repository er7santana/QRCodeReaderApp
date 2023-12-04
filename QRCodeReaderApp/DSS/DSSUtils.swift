//
//  DSSUtils.swift
//  Flame
//
//  Created by Rangel Cardoso Dias (P) on 28/09/23.
//

import Foundation

public struct DSSUtils {
    private init() {}

    public static func unicodeToString(iconCode: String) -> String {
        if let charCode = UInt32(iconCode, radix: 16), let unicodeInt = UnicodeScalar(charCode) {
            return String(unicodeInt)
        }
        
        return iconCode
    }
}
