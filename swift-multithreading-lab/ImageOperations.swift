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
