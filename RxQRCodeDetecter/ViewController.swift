//
//  ViewController.swift
//  RxQRCodeDetecter
//
//  Created by Fumiya Tanaka on 2019/02/16.
//  Copyright © 2019 Fumiya Tanaka. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var cameraView: UIView!
    
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: device!)
            
            if session.canAddInput(input) {
                
                session.addInput(input)
                
                let metadata = AVCaptureMetadataOutput()
                
                if session.canAddOutput(metadata) {
                    
                    session.addOutput(metadata)
                    
                    metadata.setMetadataObjectsDelegate(self, queue: .main)
                    metadata.metadataObjectTypes = metadata.availableMetadataObjectTypes // [.qr]
                    print(metadata.metadataObjectTypes)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: session)
                    previewLayer?.videoGravity = .resizeAspect
                    previewLayer?.connection?.videoOrientation = .portrait
                    
                    cameraView.layer.addSublayer(previewLayer!)
                    previewLayer?.frame = cameraView.bounds // addSubLayerしたCALayerはViewのサイズ変更に追従しない。
                    // 1. boundsではなくframeを変更する。
                    // 2. KVOでViewのboundsを管理し都度CALayerのframeを更新
                    // 3. layerをCALayerからCAGradientLayerに変更する。
                    
                    session.startRunning()
                    
                }
            }
            
        } catch (let error) {
            
            print(error)
            
        }
        
    }
    
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            
            if metadata.type != .qr { continue }
            
            if metadata.stringValue == nil { continue }
            
            if let url = URL(string: metadata.stringValue!) {
             
                session.stopRunning()
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
                break
                
            }
            
        }
    }
    
}
