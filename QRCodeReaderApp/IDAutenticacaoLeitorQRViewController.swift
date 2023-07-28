//
//  IDAutenticacaoLeitorQRViewController.swift
//  QRCodeReaderApp
//
//  Created by Eliezer Rodrigo Beltramin de Sant Ana on 27/07/23.
//

import UIKit
import AVFoundation

protocol QrReaderDelegate: AnyObject {
    func didRead(qrValue: String)
    func dismiss()
}

class IDAutenticacaoLeitorQRViewController: MBJBarcodeReaderViewController {
    
    private var barcodeArr = [""]
    override var metadataObjsType: [AVMetadataObject.ObjectType]? {
        get { return [AVMetadataObject.ObjectType.qr] }
        set {}
    }
    
    open weak var delegate: QrReaderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barcodeArr.removeAll()
        
        startReading()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopReading()
        delegate?.dismiss()
    }
    
    @IBAction func tappedCancelar(_ sender: Any) {
        stopReading()
        delegate?.dismiss()
    }
    
    // MARK: - READING
    private func startReading() {
        var read = ""
        
        barcodesHandler = { barcodes in
            for barcode in barcodes {
                read = barcode.stringValue ?? ""
                guard !read.isEmpty else { continue }
                self.barcodeArr.append(read)
                
                if self.barcodeArr.count > 5 {
                    DispatchQueue.main.async(execute: {
                        self.stopReading()
                        self.delegate?.didRead(qrValue: read)
                    })
                }
            }
        }
    }
    
    private func stopReading() {
        barcodesHandler = nil
    }
}
