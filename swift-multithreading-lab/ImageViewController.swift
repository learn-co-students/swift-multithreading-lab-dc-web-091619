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
    let filtersToApply = ["CISepiaTone",
                          "CIExposureAdjust"]
    
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
            startProcess()
        case .filtered:
            let alert = UIAlertController(title: "Uh oh!", message: "Image was already filtered", preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            print("Image is already filtered")
        }
    }
    
}
