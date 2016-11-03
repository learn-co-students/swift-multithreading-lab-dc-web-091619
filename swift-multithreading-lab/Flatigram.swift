//
//  Flatigram.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 11/2/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit


// MARK: Flatigram class

class Flatigram {
    var image: UIImage?
    var state = ImageState.unfiltered
}

enum ImageState {
    case unfiltered, filtered
}
