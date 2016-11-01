//
//  ImageViewController.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class ImageViewController : UIViewController {
    
    var scrollView: UIScrollView!
    var imageView = UIImageView()
    var photo = Image()
    let picker = UIImagePickerController()
    var activityIndicator = UIActivityIndicatorView()
    let pendingOperations = PendingOperations()
    
    @IBOutlet weak var chooseImageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        setUpViews()
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        selectImage()
    }
    
    @IBAction func antiqueButtonTapped(_ sender: AnyObject) {
        
        switch (photo.state) {
        case .unfiltered:
            startOperations()
        default:
            print("Image is already filtered")
        }
        
        let userQueue = OperationQueue()
//        userQueue.qualityOfService = .userInitiated
        userQueue.addOperation {
            self.filterImage { (result) in
                OperationQueue.main.addOperation {
                    result ? print("Image filtering complete") : print("Image filtering did not complete")
                    self.activityIndicator.stopAnimating()
                    self.chooseImageButton.isEnabled = true
                }
            }
        }
    }
    
    func startOperations() {
        activityIndicator.startAnimating()
        chooseImageButton.isEnabled = false
        startFiltration()
    }
    
    func startFiltration(){
        if pendingOperations.filtrationInProgress.isExecuting {
            return
        }
        
        let filterer = FilterOperation(photo)
        filterer.completionBlock = {
            if filterer.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
//                self.pendingOperations.filtrationInProgress.isFinished
//                self.imageView.image =
                self.photo.state = .filtered
            })
        }
        
        pendingOperations.filtrationInProgress = filterer
        pendingOperations.filtrationQueue.addOperation(filterer)
    }
    
    func filterImage(_ completion: @escaping (Bool) -> ()) {
        
        guard let image = imageView.image, let cgimg = image.cgImage else {
            print("imageView doesn't have an image!")
            return
        }
        
        let filtersToApply = ["CISepiaTone", "CIExposureAdjust"]
        
        for filter in filtersToApply {
            photo.image = photo.image!.apply(filter: filter)
        }
        
        
        
        print("Rendering image")
        
        UIGraphicsBeginImageContextWithOptions(result.size, false, result.scale)
        result.draw(at: CGPoint.zero)
        let finalResult = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        OperationQueue.main.addOperation({
            print("Setting final result")
            self.imageView.image = finalResult
            completion(true)
        })
    }
}

extension UIImage {
    
    func apply(filter: String) -> UIImage {
        guard let cgimg = self.cgImage else { return self }
        let openGLContext = EAGLContext(api: .openGLES2)
        let context = CIContext(eaglContext: openGLContext!)
        let coreImage = CIImage(cgImage: cgimg)
        
        let ciFilter = CIFilter(name: filter)
        ciFilter?.setValue(self, forKey: kCIInputImageKey)
        ciFilter?.setValue(1, forKey: kCIInputIntensityKey)
        print("Applying \(filter)")
        
        guard let coreImageOutput = ciFilter?.value(forKey: kCIOutputImageKey) as? CIImage else {
            return self
        }
        
        let output = context.createCGImage(coreImageOutput, from: coreImageOutput.extent)
        let result = UIImage(cgImage: output!)
        
        return result
    }
}
