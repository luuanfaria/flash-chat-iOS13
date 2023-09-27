//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        print("Cliquei no botão")
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            self.errorLabel.isHidden = true
            self.emailTextfield.textColor = UIColor(named: "BrandBlue")
            self.passwordTextfield.textColor = UIColor(named: "BrandBlue")
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    
                    let errorMessage = err.localizedDescription
                    print(errorMessage)
                    
                    if errorMessage.contains("email") {
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = errorMessage
                        self.emailTextfield.textColor = .red
                        
                    } else if errorMessage.contains("password") {
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = errorMessage
                        self.passwordTextfield.textColor = .red
                    }
                } else {
                    print("Foi?")
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                }
            }
        }
    }
    
}
