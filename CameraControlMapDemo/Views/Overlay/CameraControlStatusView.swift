//
//  CameraControlStatusView.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import SwiftUI

// MARK: - CameraControlStatusView

/// A static (non-animated) banner shown when Camera Control cannot be used:
/// the device has no Camera Control, or camera access was denied.
struct CameraControlStatusView: View {

    // MARK: - Internal Properties

    let message: String
    var showsSettingsButton = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 10.0) {
            HStack(spacing: 8.0) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text(message)
                    .font(.footnote.weight(.medium))
                    .multilineTextAlignment(.leading)
            }

            if showsSettingsButton, let url = settingsURL {
                Link(Const.Overlay.openSettings, destination: url)
                    .font(.footnote.weight(.semibold))
            }
        }
        .padding(16.0)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16.0, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16.0, style: .continuous).strokeBorder(.white.opacity(0.12)))
        .padding(.horizontal, 20.0)
    }

    // MARK: - Private Properties

    private var settingsURL: URL? {
        URL(string: UIApplication.openSettingsURLString)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(colors: [.teal, .indigo], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        VStack {
            Spacer()
            CameraControlStatusView(message: Const.Overlay.unsupportedMessage)
            CameraControlStatusView(message: Const.Overlay.permissionMessage, showsSettingsButton: true)
        }
    }
}
