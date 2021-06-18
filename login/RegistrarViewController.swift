//
//  RegistrarViewController.swift
//  login
//
//  Created by Jesús Iván Lemus Cervantes on 09/06/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class RegistrarViewController: UIViewController {
    let db = Firestore.firestore()

    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var correoTF: UITextField!
    @IBOutlet weak var nombreTF: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func alertaMensaje(msj: String) {
        let alerta = UIAlertController(title: "ERROR", message: msj, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
    
    @IBAction func registrarButton(_ sender: UIButton) {
        if let email = correoTF.text, let password = passwordTF.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print("Error al crear usuario \(e.localizedDescription)")
                    if e.localizedDescription == "The email address is already in use by another account." {
                        self.alertaMensaje(msj: "Ese correo ya esta en uso, favor de crear otro")
                    } else if e.localizedDescription == "The email address is badly formatted." {
                        self.alertaMensaje(msj: "Verifica el formato de tu email")
                    } else if e.localizedDescription == "The password must be 6 characters long or more." {
                        self.alertaMensaje(msj: "Tu contraseña debe de ser de 6 caracteres o mas")
                    }
                    
                } else {
                    let documentoNombre = email
                    self.db.collection("perfiles").document(documentoNombre).setData(["usuario": email, "nombre": self.nombreTF.text ?? "\(email)", "imagen": "noimage"]) { (error) in
                        //En caso de error
                        if let e = error {
                            print("Error al guardar en Firestore \(e.localizedDescription)")
                        } else {
                            //En caso de enviar
                            print("Se guardo la info en firestore")
                        }
                    }
                    //Navegar al siguiente VC
                    self.performSegue(withIdentifier: "registroinicio", sender: self)
                }
                
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
