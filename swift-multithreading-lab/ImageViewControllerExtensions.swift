//
//  ImageViewControllerExtensions.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 10/31/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit

extension ImageViewController {
    
    func setUpViews() {
        
        scrollView = UIScrollView(frame: view.frame)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        
        setUpScrollView()
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = UIColor.cyan
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    func setUpScrollView() {
        
        if let image = imageView.image {
            scrollView.contentOffset = CGPoint(x: image.size.width/2, y: image.size.height/2)
        } else {
            guard let bull = UIImage(named: "bull") else { return }
            photo.image = bull
            imageView = UIImageView(image: photo.image)
            scrollView.contentOffset = CGPoint(x: bull.size.width/2, y: bull.size.height/2)
        }
        scrollView.contentSize = imageView.bounds.size
        setZoomScale()
    }
}

extension ImageViewController: UIScrollViewDelegate {
    
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

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        photo.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = photo.image
        imageView.contentMode = .scaleAspectFit
        self.setUpScrollView()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func selectImage() {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
}
