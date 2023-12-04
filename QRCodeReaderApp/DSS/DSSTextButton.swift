//
//  DSSTextButton.swift
//  SantanderDesignSystem
//
//  Created by Wilson Kim on 08/07/20.
//  Copyright © 2020 Wilson Kim. All rights reserved.
//

import UIKit

/// Compoennte de botão com texto + underline (similar a um hiperlink.).
open class DSSTextButton: DSSButtonFundamental {
        
    public var textColor = DSSColors.redDark1 {
        didSet { touchedDown() }
    }
    
    public var shouldAnimatePressed = true
    public var pressedTextColor = DSSColors.redDark2
    
    
    // MARK: Construtores
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public convenience init(title: String) {
        self.init(frame: .zero)
        self.title = title
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    // MARK: Overrides
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        if state == .normal {
            setUnderline(withTitle: title, textColor: textColor, forState: state)
        }
    }
    
    public override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        if state == .normal {
            self.textColor = color ?? DSSColors.redDark1
        }
        super.setTitleColor(color, for: state)
    }
    
    
    // MARK: Configurações
    private func setup() {
        setTitleColor(DSSColors.grayLight1, for: .disabled)
        
        addTarget(self, action: #selector(touchedDown), for: .touchDown)
    }
    
    func setUnderline(withTitle title: String?, textColor: UIColor, forState state: UIControl.State) {
        var textAttributtes: [NSAttributedString.Key : Any] = [:]
        textAttributtes[.font] = UIFont.systemFont(ofSize: 16)
        textAttributtes[.foregroundColor] = textColor
        textAttributtes[.underlineColor] = textColor
        textAttributtes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        let normalAttributedTitle = NSAttributedString(string: title ?? "", attributes: textAttributtes)
        setAttributedTitle(normalAttributedTitle, for: state)
    }
    
    
    // MARK:  Ações de Botões
    @objc func touchedDown() {
        guard shouldAnimatePressed else { return }
        
        makeAnimation(textColor: self.pressedTextColor) { _ in
            self.makeAnimation(textColor: self.textColor, completion: nil)
        }
    }
    
    private func makeAnimation(textColor: UIColor, completion: ((Bool) -> Void)? = nil ) {
        UIView.transition(
            with: self,
            duration: 0.1,
            options: .transitionCrossDissolve,
            animations: {
                self.setUnderline(withTitle: self.titleLabel?.text, textColor: textColor, forState: .normal)
            },
            completion: completion
        )
    }
}
