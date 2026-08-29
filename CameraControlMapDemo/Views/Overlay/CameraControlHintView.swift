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
        .fixedSize()
        .offset(x: isAnimating ? 5.0 : -1.0)
        .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            // Defer the looping float until the entry transition settles; otherwise
            // the first layout pass collides with it and the text drifts outside the capsule.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isAnimating = true
            }
        }
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
        .fixedSize(horizontal: true, vertical: false)
    }

    private var chevrons: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: 1.0) {
                ForEach(0..<3) { index in
                    Image(systemName: "chevron.compact.right")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.tint)
                        .opacity(chevronOpacity(time: time, index: index))
                }
            }
        }
    }

    /// A pulse that travels left-to-right across the chevrons, so they appear to "run".
    private func chevronOpacity(time: TimeInterval, index: Int) -> Double {
        let speed = 2.6
        let phase = time * speed - Double(index) * 0.9
        let wave = (sin(phase) + 1.0) / 2.0
        return 0.25 + 0.75 * wave
    }

    private var cameraControlMark: some View {
        Capsule()
            .fill(.white)
            .frame(width: 5.0, height: 32.0)
            .shadow(color: .blue, radius: isAnimating ? 9.0 : 2.0)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(colors: [.teal, .indigo], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        CameraControlHintView(title: "Camera Control", subtitle: "Press, then slide to zoom")
    }
}
