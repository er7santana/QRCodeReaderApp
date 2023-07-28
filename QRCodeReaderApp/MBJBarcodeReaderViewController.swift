//
//  MBJBarcodeReaderViewController.swift
//  QRCodeReaderApp
//
//  Created by Eliezer Rodrigo Beltramin de Sant Ana on 27/07/23.
//

import UIKit
import AVFoundation

class MBJBarcodeReaderViewController: UIViewController {
    private var device: AVCaptureDevice?
    private var output: AVCaptureMetadataOutput!
    private var session: AVCaptureSession!

    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var focusLayer = MBJFocusLayer()
    fileprivate var cornersLayer = MBJCornersLayer()

    internal var metadataObjsType: [AVMetadataObject.ObjectType]?
    open var tapHandler: ((CGPoint) -> Void)?
    open var barcodesHandler: (([AVMetadataMachineReadableCodeObject]) -> Void)?

    // MARK: - VIEW
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear
        setupCamera()
        cornersLayer = MBJCornersLayer()
        cornersLayer.frame = view.bounds
        view.layer.insertSublayer(cornersLayer, above: videoPreviewLayer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard session != nil else { return }
        session.startRunning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard session != nil else { return }
        session.stopRunning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] (UIViewControllerTransitionCoordinatorContext) -> Void in
            guard let self = self else {return}
            self.cornersLayer.frame = self.view.bounds
            self.videoPreviewLayer?.frame = self.view.bounds
            self.focusLayer.frame = self.view.bounds


            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
        })
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        self.cornersLayer.frame = self.view.bounds
        self.videoPreviewLayer?.frame = self.view.bounds
        self.focusLayer.frame = self.view.bounds
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let connection = self.videoPreviewLayer?.connection {
            let currentDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection: AVCaptureConnection = connection

            if previewLayerConnection.isVideoOrientationSupported {
                switch orientation {
                case .portrait: self.updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                case .landscapeRight: self.updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                case .landscapeLeft: self.updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                case .portraitUpsideDown: self.updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                default: self.updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                }
            }
        }
    }
    
    // MARK: - PRIVATE
    private func captureDevice() -> AVCaptureDevice? {
        for device in AVCaptureDevice.devices(for: AVMediaType.video) {
            if device.position == AVCaptureDevice.Position.back {
                return device
            }
        }
        return nil
    }

    private func setupCamera() {
        var error: NSError?

        // pega camera traseira
        guard let dev = captureDevice() else { return }
        device = dev

        // input
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: device!)
        } catch let err as NSError {
            error = err
            input = nil
        }
        guard input != nil else {
            Logger.err(error, name: "camera")
            return
        }

        // focus mode
        do {
            try device!.lockForConfiguration()
            if device!.isFocusModeSupported(.continuousAutoFocus) {
                device!.focusMode = .continuousAutoFocus
            }
            if device!.isAutoFocusRangeRestrictionSupported {
                device!.autoFocusRangeRestriction = .none
            }
            device!.unlockForConfiguration()
        } catch let err {
            Logger.err(err, name: "barcode")
        }

        // session
        session = AVCaptureSession()
        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canSetSessionPreset(AVCaptureSession.Preset.high) {
            session.sessionPreset = AVCaptureSession.Preset.high
        }

        // previewLayer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer?.frame = self.view.bounds
        if let previewLayer = videoPreviewLayer {
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.insertSublayer(previewLayer, at: 0)
        }

        // output
        output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        } else {
            return
        }

        let queue = DispatchQueue(label: "mbj.barcodesreader.metadata", attributes: DispatchQueue.Attributes.concurrent)
        output.setMetadataObjectsDelegate(self, queue: queue)

        let metadataObjs: [AVMetadataObject.ObjectType] = metadataObjsType ?? [
            AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.ean13,
            AVMetadataObject.ObjectType.code39, AVMetadataObject.ObjectType.interleaved2of5
        ]
        output.metadataObjectTypes = metadataObjs

    }
}

// MARK: - METADATA OBJECTS DELEGATE
extension MBJBarcodeReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                       didOutput metadataObjects: [AVMetadataObject],
                       from connection: AVCaptureConnection) {

        var corners = [[Any]]()
        var barcodeObjs = [AVMetadataMachineReadableCodeObject]()
        guard
            let previewLayer = videoPreviewLayer,
            let barcodesHandler = self.barcodesHandler else { return }

        for metaObj in metadataObjects {
            guard
                let transformObj = previewLayer.transformedMetadataObject(for: metaObj),
                transformObj.isKind(of: AVMetadataMachineReadableCodeObject.self),
                let barcodeObj = transformObj as? AVMetadataMachineReadableCodeObject else { continue }

            barcodeObjs.append(barcodeObj)
            corners.append(barcodeObj.corners)
        }

        cornersLayer.cornersArray = corners
        let when = DispatchTime.now() + Double(Int64(0.4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            self.cornersLayer.cornersArray = []
        })

        if barcodeObjs.count > 0 {
            barcodesHandler(barcodeObjs)
        }
    }
}

// MARK: - LAYERS
class MBJFocusLayer: CALayer {
    // Use camera.app's focus mark size as default
    open var size = CGSize(width: 76, height: 76)
    // Use camera.app's focus mark sight as default
    open var sight: CGFloat = 6
    // Use camera.app's focus mark color as default
    open var strokeColor = (UIColor(named: "ShaftColor") ?? UIColor.yellow).cgColor

    open var strokeWidth: CGFloat = 1
    open var delay: CFTimeInterval = 1
    open var canDraw = false

    open var point : CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            DispatchQueue.main.async(execute: {
                self.canDraw = true
                self.setNeedsDisplay()
            })

            let when = DispatchTime.now() + Double(Int64(self.delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
                self.canDraw = false
                self.setNeedsDisplay()
            })
        }
    }

    override open func draw(in ctx: CGContext) {
        if !self.canDraw {
            return
        }

        ctx.saveGState()

        ctx.setShouldAntialias(true)
        ctx.setAllowsAntialiasing(true)
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.setStrokeColor(self.strokeColor)
        ctx.setLineWidth(self.strokeWidth)

        // Rect
        ctx.stroke(CGRect(x: self.point.x - self.size.width / 2.0, y: self.point.y - self.size.height / 2.0, width: self.size.width, height: self.size.height))

        // Focus
        for i in 0..<4 {
            var endPoint: CGPoint
            switch i {
            case 0:
                ctx.move(to: CGPoint(x: self.point.x, y: self.point.y - self.size.height / 2.0))
                endPoint = CGPoint(x: self.point.x, y: self.point.y - self.size.height / 2.0 + self.sight)
            case 1:
                ctx.move(to: CGPoint(x: self.point.x, y: self.point.y + self.size.height / 2.0))
                endPoint = CGPoint(x: self.point.x, y: self.point.y + self.size.height / 2.0 - self.sight)
            case 2:
                ctx.move(to: CGPoint(x: self.point.x - self.size.width / 2.0, y: self.point.y))
                endPoint = CGPoint(x: self.point.x - self.size.width / 2.0 + self.sight, y: self.point.y)
            case 3:
                ctx.move(to: CGPoint(x: self.point.x + self.size.width / 2.0, y: self.point.y))
                endPoint = CGPoint(x: self.point.x + self.size.width / 2.0 - self.sight, y: self.point.y)
            default:
                endPoint = CGPoint(x: 0, y: 0)
            }
            ctx.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        }

        ctx.drawPath(using: CGPathDrawingMode.fillStroke)

        ctx.restoreGState()
    }
}

class MBJCornersLayer: CALayer {
    open var strokeColor = (UIColor(named: "StrokeColor") ?? .green).cgColor
    open var strokeWidth: CGFloat = 2
    open var drawingCornersArray: [[CGPoint]] = []
    open var cornersArray: [[Any]] = [] {
        willSet {
            DispatchQueue.main.async(execute: {
                self.setNeedsDisplay()
            })
        }
    }

    override open func draw(in ctx: CGContext) {
        objc_sync_enter(self)

        ctx.saveGState()

        ctx.setShouldAntialias(true)
        ctx.setAllowsAntialiasing(true)
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.setStrokeColor(self.strokeColor)
        ctx.setLineWidth(self.strokeWidth)

        for corners in self.cornersArray {
            for i in 0...corners.count {
                var idx = i
                if i == corners.count {
                    idx = 0
                }
                guard let point = corners[idx] as? CGPoint else { continue }

                if i == 0 {
                    ctx.move(to: point)
                } else {
                    ctx.addLine(to: point)
                }
            }
        }

        ctx.drawPath(using: CGPathDrawingMode.fillStroke)

        ctx.restoreGState()

        objc_sync_exit(self)
    }
}

