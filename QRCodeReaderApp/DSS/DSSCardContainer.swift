//
//  DSSCardContainer.swift
//  SantanderDesignSystem
//
//  Created by Wilson Kim on 29/06/20.
//  Copyright © 2020 Wilson Kim. All rights reserved.
//

import UIKit

/// Card usado para delimitação de conteúdos que possui 3 tipos de elevação, e a opção de selecionado
public class DSSCardContainer: UIView {
    
    @objc public enum ElevationType: Int {
        case noElevation
        case firstElevation
        case secondElevation
    }
    
    ///Estado de selecionado ou não, o valor padrão é false
    public var isSelected: Bool = false {
        didSet {
            updateBorders()
            updateElevation()
        }
    }
    
    ///Os tipos de elevação são: .noElevation, .firstElevation e .secondElevation, definidos pelo DesignSystem
    @IBInspectable
    public var elevation: ElevationType = .firstElevation {
        didSet {
            updateElevation()
            updateBorders()
        }
    }
    
    /// Opção de inicializador com definição da elevação
    public init(withElevation elevation: ElevationType) {
        self.elevation = elevation
        super.init(frame: .zero)
        setupLayout()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        layer.cornerRadius = 4.0
        clipsToBounds = false
        backgroundColor = .white
        updateElevation()
    }
    
    private func updateElevation() {
        if isSelected {
            layer.removeShadow()
            return
        }
        
        /// Tipos de elevações
        switch elevation {
        case .noElevation:
            layer.removeShadow()
        case .firstElevation:
            layer.applySketchShadow(blur: 8.0)
        case .secondElevation:
            layer.applySketchShadow(blur: 16.0)
        }
    }
    
    /// Borda selecionada ou não
    private func updateBorders() {
        if isSelected {
            layer.borderColor = DSSColors.redDark1.cgColor
            layer.borderWidth = 1.0
            return
        }
        layer.borderColor = elevation == ElevationType.noElevation ? UIColor(rgb: 0xcccccc).cgColor : UIColor.clear.cgColor
        layer.borderWidth = elevation == ElevationType.noElevation ? 1.0 : 0
    }
}
