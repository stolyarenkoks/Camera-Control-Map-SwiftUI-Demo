//
//  MapView.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import MapKit
import SwiftUI

// MARK: - MapView

struct MapView: View {

    // MARK: - Private Properties

    @ObservedObject private var viewModel: ViewModel

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        Map(position: $viewModel.cameraPosition) {
            Marker(viewModel.placeTitle, coordinate: viewModel.placeCoordinate)
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea()
        .onMapCameraChange { context in
            viewModel.mapCameraChanged(to: context.camera)
        }
        .overlay(alignment: .trailing) {
            CameraControlHintView(title: viewModel.hintTitle, subtitle: viewModel.hintSubtitle)
                .padding(.trailing, 8.0)
                .offset(y: 80.0)
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}

// MARK: - Preview

#Preview {
    MapView(viewModel: .init())
}
