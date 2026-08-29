//
//  MapView.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import AVKit
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
        .overlay(alignment: .topTrailing) {
            if viewModel.isPreviewVisible {
                // Camera Control only routes its gesture to us while a capture preview
                // is present in the view hierarchy. Verified on-device that its size,
                // opacity, position and occlusion are irrelevant — only its existence
                // matters — so we keep a 1×1 fully transparent, invisible preview.
                CameraPreviewView(session: viewModel.captureSession)
                    .frame(width: 1.0, height: 1.0)
                    .opacity(.zero)
                    .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .trailing) {
            if viewModel.isHintVisible {
                CameraControlHintView(title: viewModel.hintTitle, subtitle: viewModel.hintSubtitle)
                    .padding(.trailing, 8.0)
                    .offset(y: 125.0)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isHintVisible)
        .overlay(alignment: .bottom) {
            if let message = viewModel.statusMessage {
                CameraControlStatusView(message: message, showsSettingsButton: viewModel.isSettingsButtonVisible)
                    .padding(.bottom, 24.0)
            }
        }
        .overlay(alignment: .topLeading) {
            if viewModel.isDebugOverlayVisible {
                MapDebugOverlayView(text: viewModel.debugText)
            }
        }
        .onCameraCaptureEvent { event in
            // Claim the Camera Control button so iOS routes its light-press controls to
            // our app instead of launching the system Camera. On a full press (release)
            // we recenter the map back to the starting place and zoom.
            guard event.phase == .ended else { return }
            viewModel.resetToInitial()
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
