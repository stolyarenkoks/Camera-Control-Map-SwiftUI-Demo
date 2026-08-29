//
//  CameraPreviewView.swift
//  CameraControlMapDemo
//
//  Created by Konstantin Stolyarenko on 29.08.2026.
//  Copyright © 2026 SKS. All rights reserved.
//

import AVFoundation
import SwiftUI

// MARK: - CameraPreviewView

/// A thin wrapper around `AVCaptureVideoPreviewLayer`. It sits behind the opaque
/// map only so the capture session qualifies as a real camera experience — a
/// requirement for the Camera Control button to route its gesture to our slider.
struct CameraPreviewView: UIViewRepresentable {

    // MARK: - Internal Properties

    let session: AVCaptureSession

    // MARK: - Internal Methods

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    // MARK: - PreviewView

    final class PreviewView: UIView {

        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
