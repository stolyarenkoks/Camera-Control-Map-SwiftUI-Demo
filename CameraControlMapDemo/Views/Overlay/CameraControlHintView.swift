//
//  CameraControlHintView.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import SwiftUI

// MARK: - CameraControlHintView

/// A floating hint anchored to the trailing edge that animates toward the
/// physical Camera Control button, inviting the user to slide it to zoom.
struct CameraControlHintView: View {

    // MARK: - Internal Properties

    let title: String
    let subtitle: String

    // MARK: - Private Properties

    @State private var isAnimating = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12.0) {
            textStack
            chevrons
            cameraControlMark
        }
        .padding(.vertical, 12.0)
        .padding(.leading, 16.0)
        .padding(.trailing, 10.0)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.12)))
        .shadow(color: .black.opacity(0.2), radius: 12.0, y: 4.0)
        .offset(x: isAnimating ? 6.0 : .zero)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear { isAnimating = true }
    }

    // MARK: - Private Methods

    private var textStack: some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Label(title, systemImage: "camera.aperture")
                .font(.subheadline.weight(.semibold))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var chevrons: some View {
        HStack(spacing: -3.0) {
            ForEach(0..<3) { index in
                Image(systemName: "chevron.compact.right")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.tint)
                    .opacity(isAnimating ? 1.0 : 0.2)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.18),
                        value: isAnimating
                    )
            }
        }
    }

    private var cameraControlMark: some View {
        Capsule()
            .fill(.white)
            .frame(width: 5.0, height: 34.0)
            .shadow(color: .accentColor, radius: isAnimating ? 8.0 : 2.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(colors: [.teal, .indigo], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        CameraControlHintView(title: "Camera Control", subtitle: "Slide right to zoom the map")
    }
}
