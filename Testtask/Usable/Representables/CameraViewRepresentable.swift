//
//  CameraViewRepresentable.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    var didCaptureImage: (UIImage) -> Void
    private var captureSession = AVCaptureSession()
    @State private var photoOutput: AVCapturePhotoOutput?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        setupCamera(viewController: viewController)
        
        let captureButton = UIButton(frame: CGRect(x: (viewController.view.bounds.width - 70) / 2, y: viewController.view.bounds.height - 100, width: 70, height: 70))
        captureButton.backgroundColor = .red
        captureButton.layer.cornerRadius = 35
        captureButton.addTarget(context.coordinator, action: #selector(Coordinator.capturePhoto), for: .touchUpInside)
        viewController.view.addSubview(captureButton)
        
        return viewController
    }
    
    private func setupCamera(viewController: UIViewController) {
        Task {
            guard let camera = AVCaptureDevice.default(for: .video) else { return }
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                captureSession.addInput(input)
                
                self.photoOutput = AVCapturePhotoOutput()
                if let photoOutput = photoOutput {
                    captureSession.addOutput(photoOutput)
                }
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.frame = viewController.view.bounds
                previewLayer.videoGravity = .resizeAspectFill
                viewController.view.layer.addSublayer(previewLayer)
                
                // Inicia la sesión de captura
                captureSession.startRunning()
            } catch {
                print("Error configurando la cámara: \(error)")
            }
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> CameraCoordinator {
        return CameraCoordinator(parent: self)
    }
    
    actor CameraCoordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView
        private var tempImage: UIImage?
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        @MainActor
        @objc func capturePhoto() {
            let settings = AVCapturePhotoSettings()
            Task {
                await parent.photoOutput?.capturePhoto(with: settings, delegate: self)
            }
        }
        
        nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation(), let uiImage = UIImage(data: data) else { return }
            Task { @MainActor in
                await self.parent.didCaptureImage(uiImage)
            }
        }
    }
}

