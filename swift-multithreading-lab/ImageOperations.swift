//
//  ImageOperations.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 11/1/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit

enum ImageState {
    case unfiltered, filtered, failed
}

class Image {
    var state = ImageState.unfiltered
    var image = UIImage(named: "Placeholder")
}

class FilterOperation: Operation {
    
    let image: Image
    
    init(_ image: Image) {
        self.image = image
    }
    
    override func main () {
        if let filteredImage = self.applySepiaFilter(image.image!) {
            self.image.image = filteredImage
            self.image.state = .filtered
        }
    }
    
    func applySepiaFilter(_ image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: "inputIntensity")
        let outputImage = filter?.outputImage
        
        let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let returnImage = UIImage(cgImage: outImage!)
        return returnImage
    }
}

class PendingOperations {
    lazy var filtrationInProgress = Operation()
    lazy var filtrationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }()
}
