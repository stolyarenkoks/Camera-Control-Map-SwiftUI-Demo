//
//  CameraControlManager.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import AVFoundation

// MARK: - CameraControlStatus

enum CameraControlStatus: Sendable {
    /// Availability is still being resolved.
    case checking
    /// The device exposes Camera Control and the zoom control is active.
    case available
    /// The device has no Camera Control (iPad, Simulator, or older iPhone).
    case unsupported
    /// Camera access is required but was not granted.
    case permissionDenied
}

// MARK: - CameraControlManager

/// Runs a capture session so the iPhone Camera Control button can drive a custom
/// zoom `AVCaptureSlider`. A (hidden) preview keeps the session a valid capture
/// experience so the hardware routes its light-press gesture to our control.
nonisolated final class CameraControlManager: NSObject, @unchecked Sendable {

    // MARK: - Internal Properties

    let session = AVCaptureSession()

    var onZoomChange: (@MainActor @Sendable (Double) -> Void)?
    var onStatusChange: (@MainActor @Sendable (CameraControlStatus) -> Void)?
    var onControlsActiveChange: (@MainActor @Sendable (Bool) -> Void)?

    // MARK: - Private Properties

    private let sessionQueue = DispatchQueue(label: Const.CameraControl.sessionQueueLabel)

    // MARK: - Internal Methods

    /// Starts the session for a device that may support Camera Control (a real iPhone).
    /// Simulator/iPad gating is handled by the caller before invoking this method.
    func start(initialZoom: Double) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configure(initialZoom: initialZoom)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                if granted {
                    self.configure(initialZoom: initialZoom)
                } else {
                    self.notifyStatus(.permissionDenied)
                }
            }
        default:
            notifyStatus(.permissionDenied)
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    // MARK: - Private Methods

    private func configure(initialZoom: Double) {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            self.session.beginConfiguration()
            self.addVideoInput()
            let available = self.addZoomControl(initialZoom: initialZoom)
            self.session.commitConfiguration()

            if available {
                self.session.startRunning()
            }

            print("[CameraControl] controls available: \(available)")
            self.notifyStatus(available ? .available : .unsupported)
        }
    }

    private func addVideoInput() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("[CameraControl] no video input available")
            return
        }
        session.addInput(input)
    }

    private func addZoomControl(initialZoom: Double) -> Bool {
        guard session.supportsControls else {
            print("[CameraControl] session does not support controls")
            return false
        }

        session.setControlsDelegate(self, queue: sessionQueue)

        let slider = AVCaptureSlider(Const.CameraControl.zoomTitle,
                                     symbolName: Const.CameraControl.zoomSymbol,
                                     in: 0...1)
        slider.value = Float(initialZoom)
        slider.setActionQueue(sessionQueue) { [weak self] value in
            self?.notifyZoom(Double(value))
        }

        guard session.canAddControl(slider) else {
            print("[CameraControl] cannot add zoom control")
            return false
        }
        session.addControl(slider)
        return true
    }

    private func notifyZoom(_ value: Double) {
        guard let onZoomChange else { return }
        Task { @MainActor in onZoomChange(value) }
    }

    private func notifyStatus(_ status: CameraControlStatus) {
        guard let onStatusChange else { return }
        Task { @MainActor in onStatusChange(status) }
    }

    private func notifyControlsActive(_ active: Bool) {
        guard let onControlsActiveChange else { return }
        Task { @MainActor in onControlsActiveChange(active) }
    }
}

// MARK: - AVCaptureSessionControlsDelegate

nonisolated extension CameraControlManager: AVCaptureSessionControlsDelegate {

    func sessionControlsDidBecomeActive(_ session: AVCaptureSession) {
        print("[CameraControl] controls became active")
        notifyControlsActive(true)
    }

    func sessionControlsWillEnterFullscreenAppearance(_ session: AVCaptureSession) {}

    func sessionControlsWillExitFullscreenAppearance(_ session: AVCaptureSession) {}

    func sessionControlsDidBecomeInactive(_ session: AVCaptureSession) {
        print("[CameraControl] controls became inactive")
        notifyControlsActive(false)
    }
}
