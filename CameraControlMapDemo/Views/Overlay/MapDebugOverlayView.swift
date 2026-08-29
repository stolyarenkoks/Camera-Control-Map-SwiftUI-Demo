//
//  MapDebugOverlayView.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import SwiftUI

// MARK: - MapDebugOverlayView

/// A small monospaced HUD that surfaces the live Camera Control state while debugging.
struct MapDebugOverlayView: View {

    // MARK: - Internal Properties

    let text: String

    // MARK: - Body

    var body: some View {
        Text(text)
            .font(.caption2.monospaced())
            .padding(8.0)
            .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 8.0))
            .foregroundStyle(.white)
            .padding(.leading, 12.0)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(colors: [.teal, .indigo], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        MapDebugOverlayView(text: "CC: available · idle · zoom 0.50")
    }
}
