//
//  DrawingViewModel.swift
//  PhotoEditor
//
//  Created by Vladimir Kravets on 10.09.2024.
//

import Foundation
import PencilKit
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

extension DrawingViewModel {
    func shareImage() {
        let scaledSize = CGSize(width: rect.size.width * imageScale, height: rect.size.height * imageScale)
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: imageOffset.width * imageScale, y: imageOffset.height * imageScale)
        
        let centerX = scaledSize.width / 2
        let centerY = scaledSize.height / 2
        context?.translateBy(x: centerX, y: centerY)
        context?.rotate(by: CGFloat(rotation.radians))
        context?.translateBy(x: -centerX, y: -centerY)
        
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let SwiftUIView = ZStack {
            ForEach(textBoxes) { box in
                Text(self.textBoxes[self.currentIndex].id == box.id && self.addNewBox ? "" : box.text)
                    .font(.system(size: 30))
                    .fontWeight(box.isBold ? .bold : .none)
                    .foregroundColor(box.textColor)
                    .offset(box.offset)
            }
        }
        
        let controller = UIHostingController(rootView: SwiftUIView).view!
        controller.frame = rect
        controller.backgroundColor = .clear
        canvas.backgroundColor = .clear
        
        controller.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = generatedImage else {
            print("Failed to generate image")
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    func shareImageFilter() {
        let activityViewController = UIActivityViewController(activityItems: [mainView.image], applicationActivities: nil)
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

class DrawingViewModel: ObservableObject {
    @Published var showImagePicker = false
    @Published var imageData: Data = Data(count: 0)
    
    @Published var canvas = PKCanvasView()
    @Published var toolPicker = PKToolPicker()
    
    @Published var textBoxes : [TextBox] = []
    @Published var allImages : [FilteredImage] = []
    @Published var addNewBox = false
    @Published var isImageChoosen = false
    @Published var currentIndex : Int = 0
    @Published var rect : CGRect = .zero
    @Published var showAlert = false
    @Published var message = ""
    @Published var mainView : FilteredImage!
    @Published var isEditorSelected = false
    @Published var isFilterSelected = false
    @Published var value :CGFloat = 1.0
    @Published var rotation: Angle = .zero
    @Published var scale: CGFloat = 0
    @Published var isDrawing: Bool = false
    @Published var imageScale: CGFloat = 1
    @Published var imageOffset: CGSize = CGSize.zero
    
    let filters : [CIFilter] = [
        CIFilter.sepiaTone(), CIFilter.comicEffect(), CIFilter.colorInvert(), CIFilter.photoEffectFade(), CIFilter.colorMonochrome(), CIFilter.photoEffectChrome(), CIFilter.gaussianBlur(), CIFilter.bloom()
    ]
    func loadFilter() {
        let context = CIContext()
        filters.forEach { (filter) in
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                // Safely unwrap CIImage
                if let ciImage = CIImage(data: self.imageData) {
                    filter.setValue(ciImage, forKey: kCIInputImageKey)
                    
                    // Safely unwrap filter's output image
                    guard let newImage = filter.outputImage else { return }
                    
                    // Safely create CGImage from the CIImage
                    if let cgImage = context.createCGImage(newImage, from: newImage.extent) {
                        
                        let isEditable = filter.inputKeys.count > 1
                        
                        // Safely create a UIImage and FilteredImage
                        let filteredData = FilteredImage(image: UIImage(cgImage: cgImage), filter: filter, isEditable: isEditable)
                        
                        DispatchQueue.main.async {
                            self.allImages.append(filteredData)
                            if self.mainView == nil { self.mainView = self.allImages.first }
                        }
                    }
                } else {
                    // Handle the case where the CIImage creation failed
                    print("Failed to create CIImage from imageData")
                }
            }
        }
    }
    
    func cancelImageEditing() {
        imageData = Data(count: 0)
        canvas = PKCanvasView()
        textBoxes.removeAll()
    }
    
    func cancelTextView() {
        addNewBox = false
        toolPicker.setVisible(true, forFirstResponder: canvas)
        canvas.becomeFirstResponder()
        if !textBoxes[currentIndex].isAdded {
            textBoxes.removeLast()
        }
    }
    func saveImage() {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: rect.size.width / 2, y: rect.size.height / 2)
        
        context?.rotate(by: CGFloat(rotation.radians))
        
        context?.translateBy(x: -rect.size.width / 2, y: -rect.size.height / 2)
        
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let SwiftUIView = ZStack {
            ForEach(textBoxes) { box in
                Text(self.textBoxes[self.currentIndex].id == box.id && self.addNewBox ? "" : box.text)
                    .font(.system(size: 30))
                    .fontWeight(box.isBold ? .bold : .none)
                    .foregroundColor(box.textColor)
                    .offset(box.offset)
            }
        }
        
        let controller = UIHostingController(rootView: SwiftUIView).view!
        controller.frame = rect
        controller.backgroundColor = .clear
        canvas.backgroundColor = .clear
        
        controller.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = generatedImage?.pngData() {
            UIImageWriteToSavedPhotosAlbum(UIImage(data: image)!, nil, nil, nil)
            print("saved")
            self.message = "Saved Successfully"
            self.showAlert.toggle()
        }
    }
    
    
    func updateEffect() {
        
        let context = CIContext()
        DispatchQueue.global(qos: .userInteractive).async {
            
            let CIImage = CIImage(data: self.imageData)
            let filter = self.mainView.filter
            filter.setValue(CIImage!, forKey: kCIInputImageKey)
            
            if filter.inputKeys.contains("inputRadius") {
                filter.setValue(self.value * 10, forKey: kCIInputRadiusKey)
            }
            
            if filter.inputKeys.contains("inputIntensity") {
                filter.setValue(self.value, forKey: kCIInputIntensityKey)
            }
            
            guard let newImage = filter.outputImage else {return}
            
            let cgimage = context.createCGImage(newImage, from: newImage.extent)
            
            
            
            DispatchQueue.main.async {
                self.mainView.image = UIImage(cgImage: cgimage!)
            }
        }
    }
}
