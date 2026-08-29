//
//  MapViewModel.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import AVFoundation
import Combine
import MapKit
import SwiftUI
import UIKit

extension MapView {

    // MARK: - ViewModel

    @MainActor class ViewModel: ObservableObject {

        // MARK: - Internal Properties

        @Published var cameraPosition: MapCameraPosition
        @Published private(set) var cameraControlStatus: CameraControlStatus = .checking
        @Published private(set) var controlsActive = false
        @Published private(set) var lastReceivedZoom = Const.Map.initialZoom

        var placeTitle: String { place.title }
        var placeCoordinate: CLLocationCoordinate2D { place.coordinate }
        var captureSession: AVCaptureSession { cameraControlManager.session }

        var isHintVisible: Bool { cameraControlStatus == .available && !controlsActive }
        var isSettingsButtonVisible: Bool { cameraControlStatus == .permissionDenied }

        /// A visible camera preview is required for iOS to route Camera Control to the app,
        /// so the viewfinder is shown (as a small PiP) whenever the control is available.
        var isPreviewVisible: Bool { cameraControlStatus == .available }

        var hintTitle: String { Const.Overlay.hintTitle }
        var hintSubtitle: String { Const.Overlay.hintAvailable }

        var statusMessage: String? {
            switch cameraControlStatus {
            case .unsupported: Const.Overlay.unsupportedMessage
            case .permissionDenied: Const.Overlay.permissionMessage
            case .checking, .available: nil
            }
        }

        /// Whether the debug HUD should be shown (compiled in for DEBUG builds only).
        var isDebugOverlayVisible: Bool {
            #if DEBUG
            true
            #else
            false
            #endif
        }

        var debugText: String {
            let zoom = String(format: "%.2f", lastReceivedZoom)
            return "CC: \(cameraControlStatus) · \(controlsActive ? "active" : "idle") · zoom \(zoom)"
        }

        // MARK: - Private Properties

        private let place: MapPlace
        private let cameraControlManager = CameraControlManager()
        private var center: CLLocationCoordinate2D
        private var zoom: Double

        // MARK: - Init

        init(place: MapPlace = .mock()) {
            self.place = place
            self.center = place.coordinate
            self.zoom = Const.Map.initialZoom
            self.cameraPosition = ViewModel.makeCamera(center: place.coordinate, zoom: Const.Map.initialZoom)

            setup()
        }

        // MARK: - Internal Methods

        func onAppear() {
            #if targetEnvironment(simulator)
            cameraControlStatus = .unsupported
            #else
            guard UIDevice.current.userInterfaceIdiom == .phone else {
                cameraControlStatus = .unsupported
                return
            }
            cameraControlManager.start(initialZoom: zoom)
            #endif
        }

        func onDisappear() {
            cameraControlManager.stop()
        }

        func mapCameraChanged(to camera: MapCamera) {
            center = camera.centerCoordinate
        }

        /// Full-press of the Camera Control button flies the map back to the starting
        /// place and zoom, and re-syncs the hardware slider to match.
        func resetToInitial() {
            center = place.coordinate
            zoom = Const.Map.initialZoom
            lastReceivedZoom = Const.Map.initialZoom
            cameraControlManager.setZoom(Const.Map.initialZoom)

            withAnimation(.easeInOut(duration: 0.5)) {
                cameraPosition = ViewModel.makeCamera(center: place.coordinate, zoom: Const.Map.initialZoom)
            }
        }

        // MARK: - Private Methods

        private func setup() {
            cameraControlManager.onZoomChange = { [weak self] value in
                self?.applyZoom(value)
            }
            cameraControlManager.onStatusChange = { [weak self] status in
                self?.cameraControlStatus = status
            }
            cameraControlManager.onControlsActiveChange = { [weak self] active in
                self?.controlsActive = active
            }
        }

        /// Rebuilds the camera around the current center for the latest Camera Control value.
        /// Animations are disabled so the map tracks the slider 1:1 without lag.
        private func applyZoom(_ value: Double) {
            zoom = value
            lastReceivedZoom = value

            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                cameraPosition = ViewModel.makeCamera(center: center, zoom: value)
            }
        }

        private static func makeCamera(center: CLLocationCoordinate2D, zoom: Double) -> MapCameraPosition {
            let ratio = Const.Map.minDistance / Const.Map.maxDistance
            let distance = Const.Map.maxDistance * pow(ratio, zoom)
            return .camera(MapCamera(centerCoordinate: center, distance: distance))
        }
    }
}
