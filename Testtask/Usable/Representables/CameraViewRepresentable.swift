//
//  CameraViewRepresentable.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    func makeCoordinator() -> CameraCoordinator {
        return CameraCoordinator()
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        context.coordinator.previewLayer?.frame = viewController.view.bounds
        viewController.view.layer.addSublayer(context.coordinator.previewLayer!)
        context.coordinator.startSession()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.previewLayer?.frame = uiViewController.view.bounds
    }
    
    class CameraCoordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var captureSession: AVCaptureSession?
        var photoOutput: AVCapturePhotoOutput?
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        override init() {
            super.init()
            setupCamera()
        }
        
        private func setupCamera() {
            captureSession = AVCaptureSession()
            guard let camera = AVCaptureDevice.default(for: .video) else { return }
            let input = try? AVCaptureDeviceInput(device: camera)
            
            if let input = input {
                captureSession?.addInput(input)
                photoOutput = AVCapturePhotoOutput()
                if let photoOutput = photoOutput {
                    captureSession?.addOutput(photoOutput)
                }
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer?.videoGravity = .resizeAspectFill
                captureSession?.startRunning()
            }
        }
        
        func startSession() {
            captureSession?.startRunning()
        }
        
        func stopSession() {
            captureSession?.stopRunning()
        }
        
        func capturePhoto() {
            let settings = AVCapturePhotoSettings()
            photoOutput?.capturePhoto(with: settings, delegate: self)
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation() else { return }
            let image = UIImage(data: data)
            // Maneja la imagen aquí (guardarla, mostrarla, etc.)
            print("Foto capturada: \(String(describing: image))")
        }
    }
}

