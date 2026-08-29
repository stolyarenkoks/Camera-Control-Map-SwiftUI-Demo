//
//  Application.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import SwiftUI

// MARK: - Application

@main
struct Application: App {

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            MapView(viewModel: .init())
        }
    }
}
