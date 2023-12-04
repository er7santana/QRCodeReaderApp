//
//  DSSBottomToast.swift
//  Cantabria
//
//  Created by Wilson Kim on 03/11/20.
//  Copyright © 2020 Wilson Kim. All rights reserved.
//

import UIKit

/**
 Toast customizado que vem de baixo
 */
public class DSSBottomToast: UIView, DSSBottomToastViewClickProtocol {
    
    ///ViewModel contendo as informações do Toast
    public var viewModel: DSSBottomToastViewModelProtocol = DSSBottomToastDefaultViewModel() {
        didSet {
            updateView()
        }
    }
    
    public var clickDelegate: DSSBottomToastViewClickProtocol? {
        didSet {
            updateClickDelegate()
        }
    }
    
    public var numberLinesOfMessageLabel: Int = 2 {
        didSet {
            bottomToastView.numberLinesOfMessageLabel = numberLinesOfMessageLabel
        }
    }
    
    private let animationTime = 0.4
    private var dismissTimer = 7.0
    private var timer: Timer?
    private var alertWindow: UIWindow? = UIApplication.shared.keyWindow
    private var bottomAnchorConstraint: NSLayoutConstraint?
    private var centerXAnchorConstraint: NSLayoutConstraint?
    
    private let viewMargin: CGFloat = 16
    
    private lazy var cardView: DSSCardContainer = {
        let view = DSSCardContainer()
        return view
    }()
    
    private lazy var bottomToastView: DSSBottomToastView = {
        let bottomToastView = DSSBottomToastView()
        bottomToastView.messageLabel.numberOfLines = numberLinesOfMessageLabel
        return bottomToastView
    }()
    
    ///Inicializador com a window na qual o toast será mostrado e a viewModel
    public init(withViewModel viewModel: DSSBottomToastViewModelProtocol, andWindow window: UIWindow) {
        self.viewModel = viewModel
        self.alertWindow = window
        super.init(frame: .zero)
        setup()
    }
    
    ///Inicializador com a window na qual o toast será mostrado
    public init(withWindow window: UIWindow? = nil) {
        self.alertWindow = window
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear

        setupLayout()
        setupGestureRegnizers()
        setupAlertViewLayout()
        updateView()
    }
    
    private func setupLayout() {
        guard let window = alertWindow else {
            return
        }
        
        if #available(iOS 11.0, *) {
            bottomAnchorConstraint = topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: 20)
        } else {
            bottomAnchorConstraint = topAnchor.constraint(equalTo: window.bottomAnchor, constant: 0)
        }
        centerXAnchorConstraint = centerXAnchor.constraint(equalTo: window.centerXAnchor)
        if let bottomConstraint = bottomAnchorConstraint,
            let centerX = centerXAnchorConstraint {
            window.addSubview(self, constraints: [
                widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
                bottomConstraint,
                centerX
            ])
        }
    }
    
    private func setupAlertViewLayout() {
        cardView.addSubview(equalConstraintsFor: bottomToastView)
        addSubview(bottomToastView, constraints: [
            bottomToastView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            bottomToastView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            bottomToastView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            bottomToastView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func setupGestureRegnizers() {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        leftSwipeGesture.direction = [.left]
        addGestureRecognizer(leftSwipeGesture)

        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        rightSwipeGesture.direction = [.right]
        addGestureRecognizer(rightSwipeGesture)
        
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
        upSwipeGesture.direction = [.down]
        addGestureRecognizer(upSwipeGesture)
        
        let longpressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longpressGestureAction(_:)))
        longpressGesture.minimumPressDuration = 0.1
        addGestureRecognizer(longpressGesture)
    }
    
    @objc
    private func swipeRight() {
        centerXAnchorConstraint?.constant = frame.width
        animateAndDismiss()
    }
    
    @objc
    private func swipeLeft() {
        centerXAnchorConstraint?.constant = -frame.width
        animateAndDismiss()
    }
    
    @objc
    private func swipeDownGesture() {
        self.bottomAnchorConstraint?.constant = 20
        animateAndDismiss()
    }
    
    @objc private func longpressGestureAction(_ gesture: UILongPressGestureRecognizer) {
        releaseTimer()
        if dismissTimer <= 1 {
            dismissTimer = 15
        }
        if gesture.state == .cancelled || gesture.state == .ended {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.reduceTime), userInfo: nil, repeats: true)
        }
    }
    ///Método para mostrar o Toast
    public func showAlert() {
        //Dispatch com delay por causa de problemas com animação
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.bottomAnchorConstraint?.constant = -self.bottomToastView.frame.height - (2 * self.viewMargin)
            UIView.animate(withDuration: self.animationTime, delay: 0.0, options: .curveEaseOut, animations: {
                self.superview?.layoutIfNeeded()
            }) { (_) in
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.reduceTime), userInfo: nil, repeats: true)
            }
        }
    }
    
    ///Método para mostrar o Toast
    public func showQuickAlert() {
        dismissTimer = 2.5
        showAlert()
    }
    
    @objc private func reduceTime() {
        dismissTimer -= 0.1
        if dismissTimer <= 0 {
            releaseTimer()
            swipeDownGesture()
        }
    }
    
    private func releaseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func animateAndDismiss() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.animationTime, delay: 0.0, options: .curveEaseOut, animations: {
                self.superview?.layoutIfNeeded()
            }) { (_) in
                self.removeFromSuperview()
                self.releaseTimer()
            }
        }
    }
    
    private func updateView() {
        bottomToastView.viewModel = viewModel
    }
    
    private func updateClickDelegate() {
        bottomToastView.clickDelegate = self
    }
    
    public func didClickInCallToAction() {
        self.clickDelegate?.didClickInCallToAction()
        animateFadeOut()
    }
    
    private func animateFadeOut() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCrossDissolve, animations: {
            self.alpha = 0
        }) { (completed) in
            self.removeFromSuperview()
            self.releaseTimer()
        }
    }
}
