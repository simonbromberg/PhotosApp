//
//  ImageDataProvider.swift
//  PhotosApp
//
//  Created by Simon Bromberg on 2020-07-19.
//  Copyright © 2020 Simon Bromberg. All rights reserved.
//

import Foundation

struct PhotoModel: Decodable {
	let title: String
	let url: String
}

class ImageDataProvider {
	enum DataProviderError: Error {
		case noData(Error?)
	}

	static func getImageList(_ completion: @escaping (_ list: Result<[PhotoModel], Error>) -> Void) {
		DispatchQueue.global().async {
			let models = Photos.compactMap { dic -> PhotoModel? in
				guard let title = dic["title"], let url = dic["url"] else {
					return nil
				}

				return PhotoModel(title: title, url: url)
			}

			completion(.success(models))
		}
	}

    static func getImageData(with url: URL, completion: @escaping (Result<Data, DataProviderError>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(.noData(error)))
            }
        }

        task.resume()
    }
}
