//
//  ViewController.swift
//  QRCodeReaderApp
//
//  Created by Eliezer Rodrigo Beltramin de Sant Ana on 03/08/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var qrCodeLabel: UILabel!
    
    private lazy var pickerController: UIImagePickerController = {
       let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        return pickerController
    }()

    @IBAction func didTapOnRead(_ sender: Any) {
        navigationController?.present(pickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let qrcodeImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
           let detector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [ CIDetectorAccuracy: CIDetectorAccuracyHigh]) {
            
            guard let ciImage: CIImage = CIImage(image: qrcodeImg) else {
                qrCodeLabel.text = "Erro ao ler QR Code"
                return
            }
            var qrCodeLink = ""
            
            guard let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else {
                qrCodeLabel.text = "Erro ao ler QR Code"
                return
            }
            
            for feature in features {
                qrCodeLink += feature.messageString ?? ""
            }
            
            if qrCodeLink == ""{
                qrCodeLabel.text = "Nenhum QR Code encontrado"
            } else {
                qrCodeLabel.text = qrCodeLink
            }
        } else {
            qrCodeLabel.text = "Erro ao ler QR Code"
        }
        self.dismiss(animated: true)
    }

}

