//
//  CameraControlManager.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import AVFoundation

// MARK: - CameraControlManager

/// Runs a lightweight capture session for the sole purpose of exposing a custom
/// zoom `AVCaptureSlider` on the iPhone Camera Control hardware button.
/// The camera feed itself is never displayed — only the hardware control is reused.
final class CameraControlManager: NSObject {

    // MARK: - Internal Properties

    /// Called on the main queue with the latest Camera Control zoom value (0...1).
    var onZoomChange: ((Double) -> Void)?

    /// Called on the main queue once it is known whether the device exposes Camera Control.
    var onAvailabilityChange: ((Bool) -> Void)?

    // MARK: - Private Properties

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: Const.CameraControl.sessionQueueLabel)

    // MARK: - Internal Methods

    func start(initialZoom: Double) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession(initialZoom: initialZoom)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                self?.configureSession(initialZoom: initialZoom)
            }
        default:
            notifyAvailability(false)
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    // MARK: - Private Methods

    private func configureSession(initialZoom: Double) {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            self.session.beginConfiguration()
            self.addVideoInput()
            let available = self.addZoomControl(initialZoom: initialZoom)
            self.session.commitConfiguration()

            if available {
                self.session.startRunning()
            }
            self.notifyAvailability(available)
        }
    }

    private func addVideoInput() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)
    }

    private func addZoomControl(initialZoom: Double) -> Bool {
        guard session.supportsControls else { return false }

        session.setControlsDelegate(self, queue: sessionQueue)

        let slider = AVCaptureSlider(Const.CameraControl.zoomTitle,
                                     symbolName: Const.CameraControl.zoomSymbol,
                                     in: 0...1)
        slider.value = Float(initialZoom)
        slider.setActionQueue(sessionQueue) { [weak self] value in
            DispatchQueue.main.async { self?.onZoomChange?(Double(value)) }
        }

        guard session.canAddControl(slider) else { return false }
        session.addControl(slider)
        return true
    }

    private func notifyAvailability(_ available: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.onAvailabilityChange?(available)
        }
    }
}

// MARK: - AVCaptureSessionControlsDelegate

extension CameraControlManager: AVCaptureSessionControlsDelegate {

    func sessionControlsDidBecomeActive(_ session: AVCaptureSession) {}

    func sessionControlsWillEnterFullscreenAppearance(_ session: AVCaptureSession) {}

    func sessionControlsWillExitFullscreenAppearance(_ session: AVCaptureSession) {}

    func sessionControlsDidBecomeInactive(_ session: AVCaptureSession) {}
}
