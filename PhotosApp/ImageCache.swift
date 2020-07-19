//
//  ImageCache.swift
//  PhotosApp
//
//  Created by Simon Bromberg on 2020-07-19.
//  Copyright © 2020 Simon Bromberg. All rights reserved.
//

import UIKit

class ImageCache {
	private var cache = NSCache<NSString, UIImage>()

	func cacheImageData(_ data: Data, for key: String) {
		guard let image = UIImage(data: data) else {
			return
		}

		cache.setObject(image, forKey: NSString(string: key))
	}

	func imageData(for key: String) -> UIImage? {
		guard let image = cache.object(forKey: NSString(string: key)) else {
			return nil
		}

		return image
	}
}
