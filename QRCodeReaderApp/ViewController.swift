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
    @IBOutlet weak var copyButton: UIButton!
    
    private lazy var pickerController: UIImagePickerController = {
       let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        return pickerController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideResultFields()
    }
    
    func hideResultFields() {
        qrCodeLabel.isHidden = true
        copyButton.isHidden = true
    }
    
    @IBAction func didTapOnRead(_ sender: Any) {
        navigationController?.present(pickerController, animated: true)
    }
    
    @IBAction func didTapOnScan(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IDLeitorQr") as? IDAutenticacaoLeitorQRViewController {
            vc.delegate = self
            present(vc, animated: true)
        }
    }
    
    @IBAction func didTapOnCopy(_ sender: Any) {
        UIPasteboard.general.string = qrCodeLabel.text
        guard let window = UIApplication.shared.keyWindow else { return }
        let toastViewModel = DSSToastViewModel(
            message: "Copied!",
            icon: .Checkmark,
            type: .success
        )
        DSSBottomToast(withViewModel: toastViewModel, andWindow: window).showQuickAlert()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        qrCodeLabel.isHidden = false
        
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
            
            displayQrCodeValue(qrCodeLink)
        } else {
            qrCodeLabel.text = "Erro ao ler QR Code"
        }
        self.dismiss(animated: true)
    }
    
    func displayQrCodeValue(_ qrValue: String) {
        qrCodeLabel.isHidden = false
        
        if qrValue.isEmpty {
            qrCodeLabel.text = "Nenhum QR Code encontrado"
        } else {
            qrCodeLabel.text = qrValue
            copyButton.isHidden = false
        }
    }

}

// MARK: - QrReaderDelegate
extension ViewController: QrReaderDelegate {
    func didRead(qrValue: String) {
        Logger.dbg(qrValue)
        
        displayQrCodeValue(qrValue)
        
        dismiss()
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
    
    
}

