//
//  MapViewModel.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import Combine
import MapKit
import SwiftUI

extension MapView {

    // MARK: - ViewModel

    @MainActor class ViewModel: ObservableObject {

        // MARK: - Internal Properties

        @Published var cameraPosition: MapCameraPosition
        @Published private(set) var isCameraControlAvailable = false

        var placeTitle: String { place.title }
        var placeCoordinate: CLLocationCoordinate2D { place.coordinate }

        var hintTitle: String { Const.Overlay.hintTitle }

        var hintSubtitle: String {
            isCameraControlAvailable ? Const.Overlay.hintAvailable : Const.Overlay.hintUnavailable
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
            cameraControlManager.start(initialZoom: zoom)
        }

        func onDisappear() {
            cameraControlManager.stop()
        }

        func mapCameraChanged(to camera: MapCamera) {
            center = camera.centerCoordinate
        }

        // MARK: - Private Methods

        private func setup() {
            cameraControlManager.onZoomChange = { [weak self] value in
                self?.applyZoom(value)
            }
            cameraControlManager.onAvailabilityChange = { [weak self] available in
                self?.isCameraControlAvailable = available
            }
        }

        /// Rebuilds the camera around the current center for the latest Camera Control value.
        private func applyZoom(_ value: Double) {
            zoom = value
            withAnimation(.easeOut(duration: 0.2)) {
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
