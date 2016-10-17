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
    var imageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @IBAction func antiqueButtonTapped(_ sender: AnyObject) {
        filterImage { (result) in
            result ? print("Image filtering complete") : print("Image filtering did not complete")
        }
    }
    
    func filterImage(_ completion: (Bool) -> ()) {
        
        guard let image = imageView?.image, let cgimg = image.cgImage else {
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
        
        print("Setting final result")
        self.imageView?.image = finalResult
        completion(true)
    }
}


extension ImageViewController: UIScrollViewDelegate {
    
    func setupViews() {
        
        imageView = UIImageView(image: UIImage(named: "FlatironFam"))
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.black
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.contentOffset = CGPoint(x: 800, y: 200)
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        setZoomScale()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func setZoomScale() {
        
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }
}
