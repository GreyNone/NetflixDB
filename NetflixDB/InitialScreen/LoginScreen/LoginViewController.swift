//
//  LoginViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/21/23.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var loginButton: UIButton!
    private var isShowPassword: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loginTextField.borderStyle = .none
        loginTextField.layer.cornerRadius = 10

        passwordTextField.borderStyle = .none
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.addShowButton()
        
        loginButton.layer.borderColor = UIColor.red.cgColor
        loginButton.layer.cornerRadius = 10
        loginButton.layer.borderWidth = 2
    }
    
    //MARK: - IBActions
    @IBAction func didTapOnBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnLoginButton(_ sender: UIButton) {
        guard let login = self.loginTextField.text,
              let password = self.passwordTextField.text else { return }
        
        SessionManager.shared.login(login: login,
                                    password: password) { success in
            if success {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

//MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return loginTextField == textField ? passwordTextField.becomeFirstResponder() : textField.resignFirstResponder()
    }
}


