//
//  FullScreenImageViewController.swift
//  PhotosApp
//
//  Created by Simon Bromberg on 2020-07-19.
//  Copyright © 2020 Simon Bromberg. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController, UIScrollViewDelegate {
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var label: UILabel!

	var image: UIImage?
	var text: String?

    override func viewDidLoad() {
        super.viewDidLoad()

		label.text = text
		imageView.image = image
		scrollView.maximumZoomScale = 10
    }

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
}
