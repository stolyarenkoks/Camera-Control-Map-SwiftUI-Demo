//
//  MapPlace.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import CoreLocation

// MARK: - MapPlace

struct MapPlace {
    let title: String
    let coordinate: CLLocationCoordinate2D
}

// MARK: - MapPlace Mock Extension

extension MapPlace {

    /// Marienplatz, Munich — the demo's focus point.
    nonisolated static func mock(
        title: String = "Marienplatz",
        coordinate: CLLocationCoordinate2D = .init(latitude: 48.1374, longitude: 11.5755)
    ) -> Self {
        .init(title: title, coordinate: coordinate)
    }
}
