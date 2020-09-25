//: [Previous](@previous)

import PlaygroundSupport
import UIKit

import NetworkImage

/*:
 The simplest way to display remote images in UIKit is by using `NetworkImageView`. You need to provide the URL where the image is located and optionally configure a placeholder image that will be displayed if the download fails or the URL is `nil`. When there is no cached image for the given URL, and the download takes more than a specific time, the view performs a cross-fade transition between the placeholder and the result.
 */

class MyViewController: UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .systemBackground

        let imageView = NetworkImageView()
        imageView.url = URL(string: "https://picsum.photos/id/237/300/200")

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        self.view = view
    }
}

//: [Next](@next)

PlaygroundPage.current.liveView = MyViewController()
