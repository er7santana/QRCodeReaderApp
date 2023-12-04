//
//  DSSBottomToastView.swift
//  QRCodeReaderApp
//
//  Created by Eliezer Rodrigo Beltramin de Sant Ana on 04/12/23.
//

import UIKit

///Protocolo da viewModel do `DSSBottomToastView`
public protocol DSSBottomToastViewModelProtocol {
    var message: String { get }
    var callToAction: String? { get }
    var icon: Icons? { get }
    var type: DSSBottomToastType { get }
}
public extension DSSBottomToastViewModelProtocol {
    var icon: Icons? {
        return nil
    }
    var type: DSSBottomToastType {
        return .regular
    }
}

public enum DSSBottomToastType {
    case success
    case regular
    case error
    
    var color: UIColor {
        switch self {
        case .success:
            return .systemGreen
        case .regular:
            return .darkGray
        case .error:
            return .systemRed
        }
    }
}


public class DSSToastViewModel: DSSBottomToastViewModelProtocol {
    public var message: String
    public var callToAction: String?
    public var icon: Icons?
    public var type: DSSBottomToastType
    
    public init(message: String,
         callToAction: String? = nil,
         icon: Icons? = nil,
         type: DSSBottomToastType = .regular) {
        self.message = message
        self.callToAction = callToAction
        self.icon = icon
        self.type = type
    }
}

internal struct DSSBottomToastDefaultViewModel: DSSBottomToastViewModelProtocol {
    var message: String = "Mensagem alerta toast com ícone com no máximo duas linhas de texto"
    var callToAction: String? = nil
    var icon: Icons? = .BlockInACircle
}
///Protocolo de click do botão com callToAction do bottomToast
public protocol DSSBottomToastViewClickProtocol {
    func didClickInCallToAction()
}

/**
 A View que vai dentro do `DSSBottomToast`
 */
public class DSSBottomToastView: UIView {
    
    ///ViewModel para preencher as infos do bottomToast
    public var viewModel: DSSBottomToastViewModelProtocol = DSSBottomToastDefaultViewModel() {
        didSet {
            updateView()
        }
    }
    
    public var numberLinesOfMessageLabel: Int = 2 {
        didSet {
            messageLabel.numberOfLines = numberLinesOfMessageLabel
        }
    }
    
    var clickDelegate: DSSBottomToastViewClickProtocol?
    
    private lazy var iconLabel: DSSIconLabel = {
        let icon = DSSIconLabel()
        icon.text = viewModel.icon?.stringValue
        icon.textColor = DSSColors.grayDark3
        icon.backgroundColor = .white
        icon.layer.cornerRadius = 20
        icon.clipsToBounds = true
        return icon
    }()
    
    lazy var messageLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .left
        label.text = viewModel.message
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var textButton: DSSTextButton = {
        let button = DSSTextButton()
        button.setTitle(viewModel.callToAction, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.textColor = .white
        button.pressedTextColor = .lightGray
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private lazy var cardContainer: DSSCardContainer = {
        let card = DSSCardContainer()
        card.elevation = .firstElevation
        card.backgroundColor = viewModel.type.color
        return card
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setupLayout()
    }
    
    private func setupLayout() {
        setupCardConteiner()
        setupStatusIcon()
        setupTextButton()
        setupMessageLabel()
        updateView()
    }
    
    private func setupCardConteiner() {
        addSubview(equalConstraintsFor: cardContainer)
    }
    
    private lazy var iconLabelWidthAnchorConstraint = iconLabel.widthAnchor.constraint(equalToConstant: 40)
    private lazy var iconLabelLeadingAnchorConstraint = iconLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 16)
    private func setupStatusIcon() {
        cardContainer.addSubview(iconLabel, constraints: [
            iconLabelLeadingAnchorConstraint,
            iconLabel.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 16),
            iconLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardContainer.bottomAnchor, constant: -16),
            iconLabelWidthAnchorConstraint,
            iconLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private lazy var textButtonTrailingAnchorConstraint = textButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
    private lazy var textButtonWidthAnchorConstraint = textButton.widthAnchor.constraint(equalToConstant: 0)
    private func setupTextButton() {
        textButton.addTarget(self, action: #selector(didClickInCallToAction), for: .touchUpInside)
        cardContainer.addSubview(textButton, constraints: [
            textButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            textButtonTrailingAnchorConstraint
        ])
    }
    
    private func setupMessageLabel() {
        cardContainer.addSubview(messageLabel, constraints: [
            messageLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            messageLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: textButton.leadingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    @objc private func didClickInCallToAction() {
        self.clickDelegate?.didClickInCallToAction()
    }
    
    private func updateView() {
        updateIconLabel()
        updateMessageLabel()
        updateTextButton()
        updateCardContainer()
        
        layoutIfNeeded()
    }
    
    private func updateIconLabel() {
        iconLabel.setupIcons(icon: viewModel.icon)
        iconLabel.isHidden = viewModel.icon == nil
        iconLabelWidthAnchorConstraint.constant = viewModel.icon == nil ? 0 : 40
        iconLabelLeadingAnchorConstraint.constant = viewModel.icon == nil ? 0 : 16
    }
    
    private func updateCardContainer() {
        cardContainer.backgroundColor = viewModel.type.color
    }
    
    private func updateMessageLabel() {
        messageLabel.text = viewModel.message
    }
    
    private func updateTextButton() {
        textButton.setTitle(viewModel.callToAction, for: .normal)
        textButton.isHidden = viewModel.callToAction == nil
        textButtonTrailingAnchorConstraint.constant = viewModel.callToAction == nil ? 0 : -16
        textButtonWidthAnchorConstraint.isActive = viewModel.callToAction == nil
    }
}

