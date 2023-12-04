//
//  DSSButtonFundamental.swift
//  Flame
//
//  Created by Guilherme Santiago Reis (P) on 28/08/23.
//

import UIKit

/// Classe base para todos os botões do Flame
open class DSSButtonFundamental: UIButton {
    
    /// Define o título do botão para o tipo .normal
    public var title: String? {
        get { self.title(for: .normal) }
        set (value) { setTitle(value, for: .normal) }
    }
    
    /// Define a cor do título do botão para o tipo .normal
    public var titleColor: UIColor? {
        get { self.titleColor(for: .normal) }
        set (value) { setTitleColor(value, for: .normal) }
    }
    
    /// Boleano que diz se já existe algum target configurado
    private(set) var hasTargetConfigured: Bool = false
    
    /// Ação que o botão vai ter.
    ///
    /// Ao adicionar a ação, automaticamente vai definir o target. Cuidado para não definir um outro target também.
    public var action: ((UIButton) -> Void)? {
        didSet { setupButtonAction() }
    }
    
    
    // MARK: Contrutores
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    // Inicializador usado para Storyboard, evite de usar!
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        action = nil
    }
    
    
    // MARK: Ações do botão
    @objc final internal func buttonAction() {
        action?(self)
    }
    
    
    // MARK: Configurações
    final private func setupButtonAction() {
        let hasAction = action != nil
        if hasAction {
            if !hasTargetConfigured {
                addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            }
        } else {
            removeTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        }
        
        hasTargetConfigured = hasAction
    }
    
    open func configureButton() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Simula o toque do botão
    ///
    /// Usado principalmente para testes unitários
    final func performTap() {
        sendActions(for: .touchUpInside)
    }
}
