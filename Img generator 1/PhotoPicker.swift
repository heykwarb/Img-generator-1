//
//  PhotoPicker.swift
//  Img generator 1
//
//  Created by Yohey Kuwabara on 2022/10/17.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @ObservedObject var vision: VisionModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var image: UIImage?
    @Binding var movieUrl: URL?
    
    @Binding var photoIsPicked: Bool
    @Binding var movieIsPicked: Bool

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        ///configuration.filter = .videos // pick videos
        configuration.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {

        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

            parent.dismiss()

            guard let provider = results.first?.itemProvider else {
                return
            }

            let typeIdentifier = UTType.movie.identifier
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        withAnimation(){
                            self.parent.vision.pickedImage = image as? UIImage
                            self.parent.movieIsPicked = false
                            self.parent.photoIsPicked = true
                            self.parent.vision.success = false
                            print("picked a photo")
                        }
                    }
                }
            }
            
            if provider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                    if let error = error {
                        print("error: \(error)")
                        return
                    }
                    if let url = url {
                        let fileName = "\(Int(Date().timeIntervalSince1970)).\(url.pathExtension)"
                        let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                        try? FileManager.default.copyItem(at: url, to: newUrl)
                        self.parent.movieUrl = newUrl
                        print("picked a movie")
                        withAnimation(){
                            self.parent.photoIsPicked = false
                            self.parent.movieIsPicked = true
                            ///self.parent.vision.success = false
                        }
                    }
                }
            }
        }
    }
}
