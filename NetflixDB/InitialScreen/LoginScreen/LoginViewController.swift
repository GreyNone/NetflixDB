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
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MGNhZGEwMmVlMDNkMGY2NGI2OTUyZmM1ZTRjYjY5MyIsInN1YiI6IjY0OTU3NGEzZDVmZmNiMDBjNTk0YjM3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SYCl9DneiRF3uQ7rbXeRp1JEJ52-3h3ODaBLBhWDy4c"
        ]
        let parameters = [
            "request_token": "\(SessionManager.shared.requestToken)"
        ] as [String : Any]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/authentication/session/new")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                guard let data = data,
                      let fetchedData = try? JSONDecoder().decode(Session.self, from: data) else { return }
                SessionManager.shared.write(session: fetchedData.sessionId)
                SessionManager.shared.set(isUserLoggedIn: fetchedData.success)
                
                if fetchedData.success {
                    let mainTabBarController = MainTabBarController()
                    self.navigationController?.pushViewController(mainTabBarController, animated: true)
                }
            }
        })
        
        dataTask.resume()
    }
}

//MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return loginTextField == textField ? passwordTextField.becomeFirstResponder() : textField.resignFirstResponder()
    }
}


