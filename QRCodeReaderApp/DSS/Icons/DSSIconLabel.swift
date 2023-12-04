//
//  DSSIconLabel.swift
//  SantanderDesignSystem
//
//  Created by Wilson Kim on 03/07/20.
//  Copyright © 2020 Wilson Kim. All rights reserved.
//

import UIKit

/**
 Label com a fonte que contém todos os ícones necessários no DesignSystem. Para definir o tamanho do ícone, altere o tamanho da fonte. O padrão é que o tamanho do Label seja 48x48 e o tamanho da fonte 24.
 */

public class DSSIconLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        textColor = DSSColors.grayDark3
        textAlignment = .center
        numberOfLines = 1
    }
    
    @available(*, deprecated, message: "Função não aplicada, tamanho padrão do ícone é 24px")
    public func setFontSize(_ size: CGFloat) {}
    
    /// Função usada para definir o ícone que será apresentado.
    public func setupIcons(icon: Icons?) {
       let unwrappedCode = icon?.stringValue ?? ""
        
        font = DSSTypography.newIconsFont()
        text = DSSUtils.unicodeToString(iconCode: unwrappedCode)
    }
    
    @available(*, deprecated, message: "Função depreciada, por favor altere para .setupIcons(icon:)")
    public func setIcon(withCode code: String?) {
        font = DSSTypography.iconsFont()
        text = DSSUtils.unicodeToString(iconCode: code ?? "")
    }
}
