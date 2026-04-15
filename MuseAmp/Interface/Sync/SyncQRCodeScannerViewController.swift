//
//  SyncQRCodeScannerViewController.swift
//  MuseAmp
//
//  Created by OpenAI on 2026/04/12.
//

@preconcurrency import AVFoundation
import SnapKit
import UIKit

#if !targetEnvironment(macCatalyst)
    final class SyncQRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
        private let captureSession = AVCaptureSession()
        private let onCodeScanned: (String) -> Void
        private let previewLayer = AVCaptureVideoPreviewLayer()
        private var hasFinished = false
        private var captureDevice: AVCaptureDevice?
        private var rotationCoordinator: AnyObject?
        private var rotationObservation: NSKeyValueObservation?

        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black

            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            let closeButton = UIButton(type: .system)
            closeButton.tintColor = .white
            closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
            view.addSubview(closeButton)
            closeButton.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
                make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
                make.size.equalTo(CGSize(width: 32, height: 32))
            }

            configureCaptureSession()
            configureRotation()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            previewLayer.frame = view.bounds
            if #unavailable(iOS 17.0) {
                updatePreviewOrientationLegacy()
            }
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            let session = captureSession
            DispatchQueue.global(qos: .userInitiated).async {
                if !session.isRunning {
                    session.startRunning()
                }
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            let session = captureSession
            DispatchQueue.global(qos: .userInitiated).async {
                if session.isRunning {
                    session.stopRunning()
                }
            }
        }

        override func viewWillTransition(
            to size: CGSize,
            with coordinator: any UIViewControllerTransitionCoordinator,
        ) {
            super.viewWillTransition(to: size, with: coordinator)
            if #unavailable(iOS 17.0) {
                coordinator.animate(alongsideTransition: { _ in
                    self.updatePreviewOrientationLegacy()
                })
            }
        }

        func metadataOutput(
            _: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from _: AVCaptureConnection,
        ) {
            guard !hasFinished,
                  let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  object.type == .qr,
                  let value = object.stringValue
            else {
                return
            }

            hasFinished = true
            captureSession.stopRunning()
            dismiss(animated: true) { [onCodeScanned] in
                onCodeScanned(value)
            }
        }

        @objc func closeTapped() {
            dismiss(animated: true)
        }

        private func configureCaptureSession() {
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device)
            else {
                return
            }

            captureDevice = device

            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            let output = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: .main)
                output.metadataObjectTypes = [.qr]
            }
        }

        private func configureRotation() {
            if #available(iOS 17.0, *) {
                guard let device = captureDevice else { return }
                let coordinator = AVCaptureDevice.RotationCoordinator(
                    device: device,
                    previewLayer: previewLayer,
                )
                rotationCoordinator = coordinator
                previewLayer.connection?.videoRotationAngle = coordinator.videoRotationAngleForHorizonLevelPreview
                rotationObservation = coordinator.observe(
                    \.videoRotationAngleForHorizonLevelPreview,
                    options: .new,
                ) { [weak self] coord, _ in
                    let angle = coord.videoRotationAngleForHorizonLevelPreview
                    DispatchQueue.main.async {
                        self?.previewLayer.connection?.videoRotationAngle = angle
                    }
                }
            }
        }

        private func updatePreviewOrientationLegacy() {
            guard let connection = previewLayer.connection, connection.isVideoOrientationSupported else {
                return
            }
            let interfaceOrientation = view.window?.windowScene?.interfaceOrientation ?? .portrait
            switch interfaceOrientation {
            case .portrait: connection.videoOrientation = .portrait
            case .landscapeLeft: connection.videoOrientation = .landscapeLeft
            case .landscapeRight: connection.videoOrientation = .landscapeRight
            case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
            default: connection.videoOrientation = .portrait
            }
        }
    }
#endif
