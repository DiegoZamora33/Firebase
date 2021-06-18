//
//  InicioViewController.swift
//  login
//
//  Created by Jesús Iván Lemus Cervantes on 12/06/21.
//

import UIKit
import Firebase
import FirebaseFirestore


class InicioViewController: UIViewController {

    var chats = [Mensaje]()
    var nombres = [String]()
    var miIndice: Int?
    var contactoSelected: Mensaje?
    var miNombre: String?
    
    //Agregar la referencia a la BD Firestore
    let db = Firestore.firestore()
    
    @IBOutlet weak var mensajeEnviarTF: UITextField!
    @IBOutlet weak var tablaChat: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Delegados de miTabla
        tablaChat.delegate = self
        tablaChat.dataSource = self
        
        /// Registrar mi Celda Personalizada
        tablaChat.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "miCeldaCustom")
        
        //ocultar el boton de regresar
        navigationItem.hidesBackButton = true
        
        /// Cargando mis Chats
        cargarChats()
    }
    
    func cargarChats() {
        db.collection("mensajes").order(by: "fechaCreacion").addSnapshotListener() { (querySnapshot, err) in
            
            /// Limpiamos mi Arreglo
            self.chats = []
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                /// Recorriendo mis Documentos
                if let snapshotDocumentos = querySnapshot?.documents{
                    
                    for document in snapshotDocumentos {
                        /// Llenando mi Arreglo de Chats
                        let datos = document.data()
                        
                        guard let miRemitente = datos["remitente"] as? String  else {
                            return
                        }
                        
                        guard let miCuerpo = datos["mensaje"] as? String  else {
                            return
                        }
                        
                        self.chats.append(Mensaje(remitente: miRemitente, cuerpoMsj: miCuerpo))
                        
                        DispatchQueue.main.async {
                            self.tablaChat.reloadData()
                        }
                        
                    }
                    
                }
                
                
            }
        }
    }
    
    @IBAction func enviarButton(_ sender: UIButton) {
        if let mensaje = mensajeEnviarTF.text, let remitente = Auth.auth().currentUser?.email {
            db.collection("mensajes").addDocument(data: [
                "remitente": remitente,
                "mensaje": mensaje,
                "fechaCreacion": Date().timeIntervalSince1970
            ]) { (error) in
                //si hubo errro
                if let e = error {
                    print("Error al guardar en Firestore \(e.localizedDescription)")
                } else {
                    
                    print("Se guardo la info en firestore")
                    self.mensajeEnviarTF.text = ""
                }
            }
        }
    }
    @IBAction func salirButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        print("Cerro sesion correctamente")
        navigationController?.popToRootViewController(animated: true)
    do {
      try firebaseAuth.signOut()
    } catch let error as NSError {
        print ("Error al cerrar sesiont: \(error.localizedDescription)")
    }
      
    }

}


// MARK: - Extension Tabla
extension InicioViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    /// Render de cada Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// Mi celda Reutilizable
        let celda = tablaChat.dequeueReusableCell(withIdentifier: "miCeldaCustom", for: indexPath) as! TableViewCell
        
        celda.nombre.text = self.chats[indexPath.row].remitente
        celda.texto.text = self.chats[indexPath.row].cuerpoMsj
        
        let perfil = self.db.collection("perfiles").document(chats[indexPath.row].remitente)
                perfil.getDocument{ (document, error) in
                    if let document = document, document.exists {
                        self.nombres.append(document.data()!["nombre"]! as! String)
                        celda.nombre.text = "De: \(document.data()!["nombre"]!)"
                        let urlString = document.data()!["imagen"] as? String
                        let url = URL(string: urlString!)

                        DispatchQueue.main.async { [weak self] in
                            if let data = try? Data(contentsOf: url!) {
                                if let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        celda.foto.image = image
                                    }
                                }
                            }
                        }
                        } else {
                            print("Document does not exist")
                        }
                }
        
        return celda
    }
    
    /// Height por cada Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 78
    }
    
    
    /// Select una Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tablaChat.deselectRow(at: indexPath, animated: true)
        
        /// Elegimos el contacto seleccionado
        contactoSelected = chats[indexPath.row]
        miIndice = indexPath.row
        miNombre = nombres[indexPath.row]
        
        performSegue(withIdentifier: "Editar", sender: self)
    }
    
    
    /// Override Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Editar"
        {
            let editarVC = segue.destination as! EditarViewController
            
            /// Mandamos mi Contacto
            editarVC.miContacto = contactoSelected
            editarVC.indice = miIndice
            editarVC.nombreUsuario = miNombre
        }
    }

}
