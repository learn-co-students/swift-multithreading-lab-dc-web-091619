//
//  UIImageExtensions.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 11/2/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit


// MARK: UIImage filtering extension
// TODO: Create a shared context for all filter applications
extension UIImage {
    
    func filter(with filter: String) -> UIImage? {
        
        UIGraphicsBeginImageContext(self.size)
        
        let image = CIImage(image: self)
        
        guard let cgContext = UIGraphicsGetCurrentContext() else { return self }
        let ciContext = CIContext(cgContext: cgContext, options: nil)
        
        guard let ciFilter = CIFilter(name: filter) else { print("Invalid filter"); return self }
        ciFilter.setValue(image, forKey: kCIInputImageKey)
        
        guard let ciImage = ciFilter.outputImage else { print("Failed to get filter output"); return self }
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        let result = UIImage(cgImage: cgImage)
        result.draw(at: CGPoint.zero)
        
        guard let finalResult = UIGraphicsGetImageFromCurrentImageContext() else { print("Could not save final UIImage"); return nil }
        
        UIGraphicsEndImageContext()
        
        print("\(filter) applied to image")
        
        return finalResult
        
    }
    
}

/*
 
 THIS CODE SHOULD WORK:
 
 func filter(with filter: String) -> UIImage? {
 
    let image = CIImage(image: self)
    let context = CIContext()
 
    guard let ciFilter = CIFilter(name: filter) else { print("Invalid filter"); return self }
    ciFilter.setValue(image, forKey: kCIInputImageKey)
 
    guard let ciImage = ciFilter.outputImage else { print("Failed to get filter output"); return self }
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
 
    let finalImage = UIImage(cgImage: cgImage)
 
    return finalImage
 
 }
 
 */
