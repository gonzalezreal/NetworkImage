# NetworkImage
[![CI](https://github.com/gonzalezreal/NetworkImage/workflows/CI/badge.svg)](https://github.com/gonzalezreal/NetworkImage/actions?query=workflow%3ACI)
![Swift 5.3](https://img.shields.io/badge/Swift-5.3-blue.svg)
![Platforms](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS-blue.svg?style=flat)
[![Twitter: @gonzalezreal](https://img.shields.io/badge/twitter-@gonzalezreal-blue.svg?style=flat)](https://twitter.com/gonzalezreal)

NetworkImage is a Swift µpackage that provides image downloading, caching, and displaying for your SwiftUI apps. It leverages the foundation URLCache, providing persistent and in-memory caches.

You can explore all the capabilities of this package in the [companion playground](/Playgrounds/NetworkImage.playground).

* [Displaying network images](#displaying-network-images)
* [Customizing network images](#customizing-network-images)
* [Creating custom network image styles](#creating-custom-network-image-styles)
* [Displaying network images in UIKit](#displaying-network-images-UIKit)
* [Using the shared ImageDownloader](#using-the-shared-imageDownloader)
* [Installation](#installation)
* [Help & Feedback](#help--feedback)
 
## Displaying network images
You can use a `NetworkImage` view to display an image from a given URL. The download happens asynchronously, and the resulting image is cached both in disk and memory.

```swift
struct ContentView: View {
    var body: some View {
        NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
            .frame(width: 300, height: 200)
    }
}
```

By default, remote images are resizable and fill the available space while maintaining the aspect ratio.

## Customizing network images
You can customize a network image's appearance by using a network image style. The default image style is an instance of `ResizableNetworkImageStyle` configured to `fill` the available space. To set a specific style for all network images within a view, you can use the `networkImageStyle(_:)` modifier.

```swift
struct ContentView: View {
    var body: some View {
        HStack {
            NetworkImage(url: URL(string: "https://picsum.photos/id/1025/300/200"))
                .frame(width: 200, height: 200)
            NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
                .frame(width: 200, height: 200)
        }
        .networkImageStyle(
            ResizableNetworkImageStyle(
                backgroundColor: .yellow,
                contentMode: .fit
            )
        )
    }
}
```

## Creating custom network image styles
To add a custom appearance, create a type that conforms to the `NetworkImageStyle` protocol. You can customize a network image's appearance in all of its different states: loading, displaying an image or failed.

```swift
struct RoundedImageStyle: NetworkImageStyle {
    var width: CGFloat?
    var height: CGFloat?

    func makeBody(state: NetworkImageState) -> some View {
        ZStack {
            Color(.secondarySystemBackground)

            switch state {
            case .loading:
                EmptyView()
            case let .image(image, _):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failed:
                Image(systemName: "photo")
                    .foregroundColor(Color(.systemFill))
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
```

Then set the custom style for all network images within a view, using the `networkImageStyle(_:)` modifier:

```swift
struct ContentView: View {
    var body: some View {
        HStack {
            NetworkImage(url: URL(string: "https://picsum.photos/id/1025/300/200"))
            NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
        }
        .networkImageStyle(
            RoundedImageStyle(width: 200, height: 200)
        )
    }
}
```

## Displaying network images in UIKit
The simplest way to display remote images in UIKit is by using `NetworkImageView`. You need to provide the URL where the image is located and optionally configure a placeholder image that will be displayed if the download fails or the URL is `nil`. When there is no cached image for the given URL, and the download takes more than a specific time, the view performs a cross-fade transition between the placeholder and the result.

```swift
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
```

## Using the shared ImageDownloader
If you need a more customized behavior, like applying image transformations or providing custom animations, you can use the shared `ImageDownloader` object directly.

<details>
  <summary>Click to expand!</summary>
  
  ```swift
  class MyViewController: UIViewController {
      private lazy var imageView = UIImageView()
      private var cancellables: Set<AnyCancellable> = []

      override func loadView() {
          let view = UIView()
          view.backgroundColor = .systemBackground

          imageView.translatesAutoresizingMaskIntoConstraints = false
          imageView.backgroundColor = .secondarySystemBackground
          view.addSubview(imageView)

          NSLayoutConstraint.activate([
              imageView.widthAnchor.constraint(equalToConstant: 300),
              imageView.heightAnchor.constraint(equalToConstant: 200),
              imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
          ])

          self.view = view
      }

      override func viewDidLoad() {
          super.viewDidLoad()

          ImageDownloader.shared.image(for: URL(string: "https://picsum.photos/id/237/300/200")!)
              .map { image in
                  // tint the image with a yellow color
                  UIGraphicsImageRenderer(size: image.size).image { _ in
                      image.draw(at: .zero)
                      UIColor.systemYellow.setFill()
                      UIRectFillUsingBlendMode(CGRect(origin: .zero, size: image.size), .multiply)
                  }
              }
              .replaceError(with: UIImage(systemName: "film")!)
              .receive(on: DispatchQueue.main)
              .sink(receiveValue: { [imageView] image in
                  imageView.image = image
              })
              .store(in: &cancellables)
      }
  }
  ```
</details>

## Installation
**Using the Swift Package Manager**

Add NetworkImage as a dependency to your `Package.swift` file. For more information, see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

```
.package(url: "https://github.com/gonzalezreal/NetworkImage", from: "1.1.0")
```

## Help & Feedback
- [Open an issue](https://github.com/gonzalezreal/NetworkImage/issues/new) if you need help, if you found a bug, or if you want to discuss a feature request.
- [Open a PR](https://github.com/gonzalezreal/NetworkImage/pull/new/master) if you want to make some change to `NetworkImage`.
- Contact [@gonzalezreal](https://twitter.com/gonzalezreal) on Twitter.
