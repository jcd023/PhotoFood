//
//  ViewController.swift
//  PhotoFood
//
//  Created by Joseph Duckwall on 9/19/24.
//  Based on information provided by iOS academy for creating adding a camera view to an application
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    //Make the capture session that we will be using
    var session: AVCaptureSession?
    //Get the Photo Output
    let output = AVCapturePhotoOutput()
    //Make sure there is a video preview
    let preview = AVCaptureVideoPreviewLayer()
    //Functionality for the camera shutter button
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        button.layer.cornerRadius = 100
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Camera Search"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backSelf))
        
        view.backgroundColor = .black
        view.layer.addSublayer(preview)
        view.addSubview(shutterButton)
        
        checkCameraPermissions()
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview.frame = view.bounds
        
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 100)
    }
    
    private func checkCameraPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            //Request permission
            AVCaptureDevice.requestAccess(for: .video) { [weak self] permission in
                guard permission else {
                    return
                }
                DispatchQueue.main.async{
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }

    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video){
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                
                preview.videoGravity = .resizeAspectFill
                preview.session = session
                
                session.startRunning()
                self.session = session
            }
                
            catch{
                print(error)
            }
        }
        
    }
    
    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error:
        Error?){
        guard let data = photo.fileDataRepresentation() else{
            return
        }
        let image = UIImage(data: data)
        
        session?.stopRunning()
        
        let imageView = UIImageView(image:image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
    @objc private func backSelf(){
        dismiss(animated: true, completion: nil)
    }
}
