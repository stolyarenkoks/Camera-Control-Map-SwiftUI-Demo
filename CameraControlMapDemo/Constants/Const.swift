//
//  Const.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import Foundation

// MARK: - Const

enum Const {

    // MARK: - Map

    enum Map {
        /// Camera distance range (in meters) mapped to the normalized zoom value.
        static let minDistance: Double = 500.0
        static let maxDistance: Double = 20_000_000.0

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
        static let hintAvailable = "Slide right to zoom the map"
        static let hintUnavailable = "Needs an iPhone with Camera Control"
    }
}
