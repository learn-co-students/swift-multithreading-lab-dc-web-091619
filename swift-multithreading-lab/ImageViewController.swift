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
    var activityIndicator = UIActivityIndicatorView()
    let picker = UIImagePickerController()
    
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
        
        activityIndicator.startAnimating()
        
        chooseImageButton.isEnabled = false
        
        let userQueue = OperationQueue()
        userQueue.qualityOfService = .userInitiated
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
    
    func filterImage(_ completion: @escaping (Bool) -> ()) {
        
        guard let image = imageView.image, let cgimg = image.cgImage else {
            print("imageView doesn't have an image!")
            return
        }
        
        let openGLContext = EAGLContext(api: .openGLES2)
        let context = CIContext(eaglContext: openGLContext!)
        let coreImage = CIImage(cgImage: cgimg)
        
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(1, forKey: kCIInputIntensityKey)
        print("Applying CISepiaTone")
        
        guard let sepiaOutput = sepiaFilter?.value(forKey: kCIOutputImageKey) as? CIImage else {
            completion(false)
            return
        }
        
        let exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter?.setValue(sepiaOutput, forKey: kCIInputImageKey)
        exposureFilter?.setValue(1, forKey: kCIInputEVKey)
        print("Applying CIExposureAdjust")
        
        guard let exposureOutput = exposureFilter?.value(forKey: kCIOutputImageKey) as? CIImage else {
            completion(false)
            return
        }
        
        let output = context.createCGImage(exposureOutput, from: exposureOutput.extent)
        let result = UIImage(cgImage: output!)
        
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
