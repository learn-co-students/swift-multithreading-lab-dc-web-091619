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


//MARK: Image View Controller

class ImageViewController : UIViewController {
    
    var scrollView: UIScrollView!
    var imageView = UIImageView()
    var flatigram = Flatigram()
    let picker = UIImagePickerController()
    var activityIndicator = UIActivityIndicatorView()
    let pendingOperations = PendingOperations()
    let filtersToApply = ["CIBloom",
                          "CIPhotoEffectProcess",
                          "CIExposureAdjust"]

    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var chooseImageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        setUpViews()
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        selectImage()
    }
    
    @IBAction func filterButtonTapped(_ sender: AnyObject) {
        switch (flatigram.state) {
        case .unfiltered:
            startProcess()
        case .filtered:
            presentFilteredAlert()
        }
    }
    
    func presentFilteredAlert() {
        let alert = UIAlertController(title: "Uh oh!", message: "Image was already filtered", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        print("Image is already filtered")
    }
    
}


// MARK: Image Functions

extension ImageViewController {
    
    func startProcess() {
        
        activityIndicator.startAnimating()
        filterButton.isEnabled = false
        chooseImageButton.isEnabled = false
        
        filterImage { result in
            
            OperationQueue.main.addOperation {
                result ? print("Image successfully filtered") : print("Image filtering did not complete")
                self.imageView.image = self.flatigram.image
                self.activityIndicator.stopAnimating()
                self.filterButton.isEnabled = true
                self.chooseImageButton.isEnabled = true
            }
        }
    }
    
    func filterImage(_ completion: @escaping (Bool) -> ()) {
        
        guard !pendingOperations.filtrationInProgress.isExecuting else { completion(false); return }
        
        for filter in filtersToApply {
            
            let filterer = FilterOperation(flatigram: flatigram, filter: filter)
            filterer.completionBlock = {
                
                if filterer.isCancelled {
                    completion(false)
                    return
                }
                
                if self.pendingOperations.filtrationQueue.operationCount == 0 {
                    DispatchQueue.main.async(execute: {
                        self.flatigram.state = .filtered
                        completion(true)
                    })
                }
            }
            
            pendingOperations.filtrationInProgress = filterer
            pendingOperations.filtrationQueue.addOperation(filterer)
        }
    }
    
}
