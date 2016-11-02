//
//  ImageOperations.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 11/1/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit

class FilterOperation: Operation {
    
    let fImage: FlatigramImage
    let filter: String
    
    init(image: FlatigramImage, filter: String) {
        self.fImage = image
        self.filter = filter
    }
    
    override func main () {
        
        if let filteredImage = self.fImage.image.filter(with: filter) {
            self.fImage.image = filteredImage
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
