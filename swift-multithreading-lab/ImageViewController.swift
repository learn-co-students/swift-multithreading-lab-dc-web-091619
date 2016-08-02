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
    }
    
    @IBAction func ageItButton(sender: AnyObject) {
        print("Starting activity indicator")
        activityIndicator.startAnimating()
        let userQueue = NSOperationQueue()
        userQueue.qualityOfService = .UserInitiated
        userQueue.addOperationWithBlock {
            self.createImage { (result) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    if result {
                        self.activityIndicator.stopAnimating()
                        print("Stopping activity indicator")
                    }
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

                
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    print("Setting the new image")
                    self.imageView?.image = result

                })
                
                print("Returning completion from createImage")
                completion(true)
            }
        }
    }
}