//
//  ImageViewController.swift
//  swift-multithreading-lab
//
//  Created by Flatiron School on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class ImageViewController : UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start the activity indicator
        print("Starting activity indicator")
        activityIndicator.startAnimating()
        
        // Create the image and tell the activity indicator to stop after the image has been created
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
            self.createImage { (result) in
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    if result { self.activityIndicator.stopAnimating(); print("Stopping activity indicator") }
                }
            }
        }
    }
    
    func createImage(completion: (Bool) -> ()) {
        
        print("Creating image")
        
        guard let image = imageView?.image, cgimg = image.CGImage else {
            print("imageView doesn't have an image!")
            completion(false)
            return
        }
        
        let openGLContext = EAGLContext(API: .OpenGLES2)
        let context = CIContext(EAGLContext: openGLContext!)
        let coreImage = CIImage(CGImage: cgimg)
        
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(1, forKey: kCIInputIntensityKey)
        
        if let sepiaOutput = sepiaFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
            let exposureFilter = CIFilter(name: "CIExposureAdjust")
            exposureFilter?.setValue(sepiaOutput, forKey: kCIInputImageKey)
            exposureFilter?.setValue(1, forKey: kCIInputEVKey)
            print("CISepiaTone applied")
            
            if let exposureOutput = exposureFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
                let output = context.createCGImage(exposureOutput, fromRect: exposureOutput.extent)
                let result = UIImage(CGImage: output)
                print("CIExposureAdjust applied")

                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    print("Setting the new image")
                    self.imageView?.image = result
                }
                
                print("Returning completion from createImage")
                completion(true)
            }
        }
        
    }
}