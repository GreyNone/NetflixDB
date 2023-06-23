//
//  LoginTextField.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/21/23.
//

import UIKit

class LoginTextField: UITextField {
    
    private let leftPadding: CGFloat = 10
    private var showButton: UIButton?
    private let showButtonWidth: CGFloat = 20
    private let showButtonHeight: CGFloat = 20
    private var isShowPassword: Bool = true
    
    func addShowButton() {
        showButton = UIButton(frame: CGRect(x: self.bounds.width,
                                            y: self.bounds.height / 2 - showButtonHeight,
                                            width: showButtonWidth,
                                            height: showButtonHeight))
        if let showButton = showButton {
            showButton.setTitle("Show", for: .normal)
            showButton.setTitleColor(.lightGray, for: .normal)
            showButton.addTarget(self, action: #selector(didTapOnShowButton(sender: )), for: .touchUpInside)
            self.rightViewMode = .always
            self.rightView = showButton
        }
    }
    
    //MARK: - Actions
    @objc func didTapOnShowButton(sender: UIButton) {
        if isShowPassword {
            self.isSecureTextEntry = false
            isShowPassword = !isShowPassword
        } else {
            self.isSecureTextEntry = true
            isShowPassword = !isShowPassword
        }
    }
    
    //MARK: - FixLayout
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = CGRect(x: leftPadding, y: 0, width: bounds.width - leftPadding, height: bounds.height)
        return bounds
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = CGRect(x: leftPadding, y: 0, width: bounds.width - leftPadding, height: bounds.height)
        return bounds
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = CGRect(x: leftPadding, y: 0, width: bounds.width - leftPadding, height: bounds.height)
        return bounds
    }
    
//    override func layoutSubviews() {
//
//    }
}
