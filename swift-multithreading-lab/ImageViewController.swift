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
    let picker = UIImagePickerController()
    var activityIndicator = UIActivityIndicatorView()
    let filtersToApply = ["CIBloom",
                          "CIPhotoEffectProcess",
                          "CIExposureAdjust"]
    var flatigram = Flatigram()
    let pendingOperations = PendingOperations()
    
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
//        for filter in filtersToApply {
//            DispatchQueue.main.async {
//                self.imageView.image = self.flatigram.image?.filter(with: filter)
//                print("filter applied!")
//            }
//        }
        switch (flatigram.state) {
        case .unfiltered:
            startProcess()
        case .filtering:
            print("nope")
        case .filtered:
            presentFilteredAlert()
        }
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
    
    func filterImage(with completion: @escaping (Bool) -> ()) {
        
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
            print("Added FilterOperation with \(filter) to \(pendingOperations.filtrationQueue.name!)")
        }
    }
    
}
