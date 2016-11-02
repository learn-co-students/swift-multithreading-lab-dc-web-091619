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
    case unfiltered, filtered
}

class Image {
    var state = ImageState.unfiltered
    var image = UIImage(named: "Placeholder")
}

class FilterOperation: Operation {
    
    let image: Image
    let filter: String
    
    init(image: Image, filter: String) {
        self.image = image
        self.filter = filter
    }
    
    override func main () {
        
        if let filteredImage = self.image.image?.filter(with: filter) {
            self.image.image = filteredImage
        }
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

extension UIImage {
    
    func filter(with filter: String) -> UIImage? {
        
        let coreImage = CIImage(data:UIImagePNGRepresentation(self)!)
        let openGLContext = EAGLContext(api: .openGLES2)
        let context = CIContext(eaglContext: openGLContext!)
        let ciFilter = CIFilter(name: filter)
        ciFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        guard let coreImageOutput = ciFilter?.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("Could not unwrap output of CIFilter: \(filter)")
            return nil
        }
        
        let output = context.createCGImage(coreImageOutput, from: coreImageOutput.extent)
        let result = UIImage(cgImage: output!)
        
        UIGraphicsBeginImageContextWithOptions(result.size, false, result.scale)
        result.draw(at: CGPoint.zero)
        guard let finalResult = UIGraphicsGetImageFromCurrentImageContext() else {
            print("Could not save final UIImage")
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        return finalResult
    }
    
}
