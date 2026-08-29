//
//  Const.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import Foundation

// MARK: - Const

nonisolated enum Const {

    // MARK: - Map

    enum Map {
        /// Camera distance range (in meters) mapped to the normalized zoom value.
        /// A narrower range keeps the exponential zoom feeling gradual end-to-end.
        static let minDistance: Double = 800.0
        static let maxDistance: Double = 6_000_000.0

        /// Normalized zoom (0...1). `1` is the closest, `0` is the farthest.
        static let initialZoom: Double = 0.55
    }

    // MARK: - Camera Control

    enum CameraControl {
        static let zoomTitle = "Map Zoom"
        static let zoomSymbol = "plus.magnifyingglass"
        static let sessionQueueLabel = "com.sks.cameracontrol.session"
    }

    // MARK: - Overlay

    enum Overlay {
        static let hintTitle = "Camera Control"
        static let hintAvailable = "Touch, then slide to zoom"
        static let unsupportedMessage = "Camera Control isn't available on this device"
        static let permissionMessage = "Enable camera access to use Camera Control"
        static let openSettings = "Open Settings"
    }
}
