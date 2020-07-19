//
//  PhotosViewController.swift
//  PhotosApp
//
//  Created by Simon Bromberg on 2020-07-19.
//  Copyright © 2020 Simon Bromberg. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet var tableView: UITableView!

	var imageCache = ImageCache()

	var photos = [PhotoModel]()

	override func viewDidLoad() {
		super.viewDidLoad()

		getImageList()
	}

	private func getImageList() {
		ImageDataProvider.getImageList { [weak self] result in
			switch result {
			case .success(let models):
				self?.photos = models
			case .failure(let error):
				print(error)
			}
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return photos.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ImageCell

		let image = getImage(at: indexPath) { [weak self] success in
			DispatchQueue.main.async {
				if success && self?.tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
					self?.tableView.reloadRows(at: [indexPath], with: .fade)
				}
			}
		}

		cell.photoView.image = image

		return cell
	}

	private func getImage(at indexPath: IndexPath, completion: ((_ success: Bool) -> Void)? = nil) -> UIImage? {
		let urlString = photos[indexPath.row].url

		if let cached = imageCache.imageData(for: urlString) {
			return cached
		} else if let url = URL(string: urlString) {
			ImageDataProvider.getImageData(with: url) { [weak self] result in
				switch result {
				case .success(let imageData):
					self?.imageCache.cacheImageData(imageData, for: urlString)
					completion?(true)
				case .failure(let error):
					print(error)
					completion?(false)
				}
			}
		}

		return nil
	}

	// MARK: - UITableViewDelegate

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let image = getImage(at: indexPath) { success in
			if success {
				DispatchQueue.main.async {
					self.performSegue(withIdentifier: self.segueToFullIdentifier, sender: nil)
				}
			}
		}

		if image != nil {
			performSegue(withIdentifier: segueToFullIdentifier, sender: nil)
		}

		tableView.deselectRow(at: indexPath, animated: true)
	}

	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
			self?.photos.remove(at: indexPath.row)
			self?.tableView.deleteRows(at: [indexPath], with: .automatic)
		}

		let configuration = UISwipeActionsConfiguration(actions: [action])
		configuration.performsFirstActionWithFullSwipe = false

		return configuration
	}

	private let segueToFullIdentifier = "ToFullScreenImage"

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == segueToFullIdentifier,
			let destination = segue.destination as? FullScreenImageViewController,
			let selection = tableView.indexPathForSelectedRow {
			let text = photos[selection.row].title
			let image = getImage(at: selection)
			destination.image = image
			destination.text = text
		}
	}
}

class ImageCell: UITableViewCell {
	@IBOutlet var photoView: UIImageView!
}
