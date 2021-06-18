//
//  EditarViewController.swift
//  login
//
//  Created by Diego Zamora on 17/06/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class EditarViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Variables y Outlets
    var miContacto: Mensaje?
    var indice: Int?
    var flag = false
    
    var nombreUsuario: String?
    let db = Firestore.firestore()
    
    @IBOutlet weak var imagenPerfil: UIImageView!
    @IBOutlet weak var nombreField: UITextField!
    @IBOutlet weak var correoField: UITextField!
    
    
    // MARK: - Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        
        getData()
        
        let gestura = UITapGestureRecognizer( target: self, action: #selector(clickImagen))
        gestura.numberOfTapsRequired = 1
        gestura.numberOfTouchesRequired = 1
        imagenPerfil.addGestureRecognizer(gestura)
        imagenPerfil.isUserInteractionEnabled = true
        imagenPerfil.layer.cornerRadius = 100
    }
    
    @objc func clickImagen(gestura: UITapGestureRecognizer) {
           print("Cambiar imagen")
           let vc = UIImagePickerController()
           vc.sourceType = .photoLibrary
           vc.delegate = self
           vc.allowsEditing = true
           present(vc, animated: true, completion: nil)
       }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           //Que se hara cuando el usuario selecciona alguna imagen
           if let imagenSeleccionada = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
               imagenPerfil.image = imagenSeleccionada
           }
           picker.dismiss(animated: true, completion: nil)
       }
       
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }
       
    @IBAction func guardarDatos(_ sender: UIButton) {
           guard let image = imagenPerfil.image, let datosImage = image.jpegData(compressionQuality: 1.0) else {
               print ("Error")
               return
           }
           let imageReferencia = Storage.storage().reference().child("perfiles").child(nombreUsuario!)
           //Subir datos a Firestorage
           imageReferencia.putData(datosImage, metadata: nil) { (metadata, error) in
               if let err = error {
                   print("Error al subir la imagen \(err.localizedDescription)")
               }
               imageReferencia.downloadURL { (url, error) in
                   if let err = error {
                       print("Error al subir la imagen \(err.localizedDescription)")
                       return
                   }
                   guard let url = url else {
                       print("Error al crear url de la imagen")
                       return
                   }
                   //Subir a Firestore
                   let dataReferencia = Firestore.firestore().collection("perfiles").document(self.nombreUsuario!)
                   let urlString = url.absoluteString
                   let datosEnviar = ["imagen": urlString, "nombre": self.nombreField.text!, "usuario": self.correoField.text!]
                   dataReferencia.setData(datosEnviar) { (error) in
                       if let err = error {
                           print("Error al mandar datos de imagen \(err.localizedDescription)")
                           return
                       } else {
                           let alerta = UIAlertController(title: "Correcto!", message: "Datos guardados correctamente", preferredStyle: .alert)
                           let accionAceptar = UIAlertAction(title: "Aceptar", style: .default)
                           alerta.addAction(accionAceptar)
                           self.present(alerta, animated: true, completion: nil)
                           
                           print("Se guardo correctamente en FS")
                       }
                   }
               }
           }
       }
    
    func getData() {
        let perfil = db.collection("perfiles").document(self.miContacto!.remitente)
        perfil.getDocument{ (document, error) in
            if let document = document, document.exists {
                self.nombreField.text = "\(String(describing: self.nombreUsuario!))"
                self.correoField.text = "\(String(describing: self.miContacto!.remitente))"
                let urlString = document.data()!["imagen"] as? String
                let url = URL(string: urlString!)
                
                DispatchQueue.main.async { [weak self] in
                    if let data = try? Data(contentsOf: url!) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self?.imagenPerfil.image = image
                            }
                        }
                    }
                }
                } else {
                    print("Document does not exist")
                }
        }
    }
}
