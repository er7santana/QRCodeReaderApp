//
//  Typography.swift
//  SantanderDesignSystem
//
//  Created by Wilson Kim on 04/08/20.
//  Copyright © 2020 Wilson Kim. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreText
import UIKit

final public class DSSTypography: NSObject {
    
    public override init() {
        super.init()
    }
    
    @available(*, deprecated, message: "Função depreciada, por favor altere para .newIconsFont()")
    public static func iconsFont(withSize size: CGFloat = 24) -> UIFont? {
        return UIFont(name: "SantanderIcons", size: size)
    }
    
    public static func newIconsFont(withSize size: CGFloat = 24) -> UIFont? {
        return UIFont(name: "SantanderIconsIos", size: size)
    }
    
    /// Carrega as fontes usadas no Flame.
    public static func loadDSSFonts() {
        loadFontWith(name: "SantanderIcons")
        loadFontWith(name: "SantanderIconsIos")
    }
    
    internal static func loadFontWith(name: String, andType type: String = "ttf") {
        let frameworkBundle = Bundle(for: DSSTypography.self)
        guard let pathForResourceString = frameworkBundle.path(forResource: name, ofType: "ttf") else {
            fatalError("No path for font")
        }
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            fatalError("No font data for font")
        }
        guard let dataProvider = CGDataProvider(data: fontData) else {
            fatalError("No provider for font")
        }
        guard let fontRef = CGFont(dataProvider) else {
            fatalError("No font for font")
        }
        if (CTFontManagerRegisterGraphicsFont(fontRef, nil) == false) {
            NSLog("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
}
