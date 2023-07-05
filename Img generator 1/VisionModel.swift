//
//  VisionModel.swift
//  Img generator 1
//
//  Created by Yohey Kuwabara on 2022/10/17.
//

import Foundation
import AVFoundation
import Vision
import CoreImage
import UIKit
import SwiftUI

class VisionModel: ObservableObject{
    @Published var pickedImage: UIImage?
    @Published var movieURL: URL?
    
    @Published var photoIsPicked = false
    @Published var movieIsPicked = false
    
    @Published var outputImage: UIImage?
    
    @Published var processing = false
    @Published var bgBlur: CGFloat = 0
    @Published var success = false
    
    @Published var pngOutputImg: Data?
    
    func styleTransfer(originalImage: UIImage){
        print("style transfer")
        
        //get original image size
        let width = originalImage.size.width
        let height = originalImage.size.height
        
        //Model
        guard let model = try? VNCoreMLModel(for: StableLLVE(configuration: MLModelConfiguration()).model) else {
            fatalError("Error create VMCoreMLModel")
        }
        
        //Request
        let request = VNCoreMLRequest(model: model)
        
        request.imageCropAndScaleOption = .scaleFit //set the scale to square because image needs to be square when implementation
        
        var squareSize: CGFloat = 0
        var cropRect = CGRect()
        
        //set the size when final cropping
        if height > width {
            print("height > width")
            squareSize = height
            cropRect = CGRect(x: (height-width)/2, y: 0, width: width, height: height)
        }else {
            print("width > height")
            squareSize = width
            cropRect = CGRect(x: 0, y: (width-height)/2, width: width, height: height)
        }
        
        //Convert to CIImage for Handler
        guard let ciImage = CIImage(image: originalImage) else {
            fatalError("Error convert CIImage")
        }
        
        //Handler
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            print("handler")
            try handler.perform([request])
            guard let result = request.results?.first as? VNPixelBufferObservation else {
                print("error on result")
                return
            }
            
            let ciOutputImage = CIImage(cvPixelBuffer: result.pixelBuffer)
            
            outputImage = UIImage(ciImage: ciOutputImage).resize(to: CGSize(width: squareSize, height: squareSize))
            outputImage = outputImage!.cropping(to: cropRect)
            ///self.outputImage = UIImage(ciImage: ciimage).resize(to: CGSize(width: width, height: height))
            
            pngOutputImg = outputImage?.pngData() //convert outputImage to png for saving
            
            withAnimation(){
                
                self.processing = false
                success = true
                bgBlur = 0
            }
            print("success!")
        } catch {
            print(error)
        }
    }
    
    func refine(originalImage: UIImage){
        print("refine")
        
        //get original image size
        let width = originalImage.size.width
        let height = originalImage.size.height
        
        //Model
        guard let model = try? VNCoreMLModel(for: realesrgan512(configuration: MLModelConfiguration()).model) else {
            fatalError("Error create VMCoreMLModel")
        }
        
        //Request
        let request = VNCoreMLRequest(model: model)
        
        request.imageCropAndScaleOption = .scaleFit //set the scale to square because image needs to be square when implementation
        
        var squareSize: CGFloat = 2048
        var cropRect = CGRect()
        
        //set the size when final cropping
        if height > width {
            print("height > width")
            let ratio = width/height
            print(ratio)
            cropRect = CGRect(x: (squareSize-squareSize*ratio)/2, y: 0, width: squareSize*ratio, height: squareSize)
        }else {
            print("width > height")
            let ratio = height/width
            print(ratio)
            cropRect = CGRect(x: 0, y: (squareSize-squareSize*ratio)/2, width: squareSize, height: squareSize*ratio)
        }
        
        print(cropRect)
        
        //Convert to CIImage for Handler
        guard let ciImage = CIImage(image: originalImage) else {
            fatalError("Error convert CIImage")
        }
        
        //Handler
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            print("handler")
            try handler.perform([request])
            guard let result = request.results?.first as? VNPixelBufferObservation else {
                print("error on result")
                return
            }
            
            let ciOutputImage = CIImage(cvPixelBuffer: result.pixelBuffer)
            
            outputImage = UIImage(ciImage: ciOutputImage).resize(to: CGSize(width: squareSize, height: squareSize))
            outputImage = outputImage!.cropping(to: cropRect)
            ///self.outputImage = UIImage(ciImage: ciimage).resize(to: CGSize(width: width, height: height))
            
            pngOutputImg = outputImage?.pngData() //convert outputImage to png for saving
            
            withAnimation(){
                
                self.processing = false
                success = true
                bgBlur = 0
            }
            print("success!")
        } catch {
            print(error)
        }
    }
    
    func extractFirstFrame() {
        print ("movieURL\(movieURL!)")     //used for debugging
        let asset = AVAsset(url: movieURL!)
        let generator = AVAssetImageGenerator.init(asset: asset)
        
        ///let time: CMTime = try await asset.load(.duration)
        ///print(time)
        
        var images: [UIImage]
        
        ///generator.generateCGImagesAsynchronously(forTimes: timesArray ) { requestedTime, image, actualTime, result, error in
             ///images[requestedTime] = UIImage(cgImage: image!)
            ///print("generate image")
        ///}
    }
}
