//
//  LoginViewController.swift
//  login
//
//  Created by Jesús Iván Lemus Cervantes on 12/06/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var correoTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        if let email = correoTF.text, let password = passwordTF.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
             
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    //NAvegar al inicio
                    self.performSegue(withIdentifier: "logininicio", sender: self)
                }
                
            }
        }
        
    }

}
