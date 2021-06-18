//
//  ViewController.swift
//  login
//
//  Created by Jesús Iván Lemus Cervantes on 08/06/21.
//

import UIKit
import CLTypingLabel

class ViewController: UIViewController {

    
    @IBOutlet weak var MensajeBienvenidaLabel: CLTypingLabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        MensajeBienvenidaLabel.charInterval = 0.05
        
        MensajeBienvenidaLabel.text = "Hola bienvenidos a la app oficial del Intituto Tecnologico de Morelia, puedes iniciar sesion o registrarte con tu correo institucional."
    
    }


}

