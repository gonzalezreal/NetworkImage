# NetworkImage
[![CI](https://github.com/gonzalezreal/NetworkImage/workflows/CI/badge.svg)](https://github.com/gonzalezreal/NetworkImage/actions?query=workflow%3ACI)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgonzalezreal%2FNetworkImage%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/gonzalezreal/NetworkImage)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgonzalezreal%2FNetworkImage%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/gonzalezreal/NetworkImage)
[![contact: @gonzalezreal](https://img.shields.io/badge/contact-@gonzalezreal-blue.svg?style=flat)](https://twitter.com/gonzalezreal)

NetworkImage is a Swift package that provides image downloading, caching, and displaying for your
SwiftUI apps. It leverages the foundation URLCache, providing persistent and in-memory caches.

You can explore all the capabilities of this package in the
[companion demo project](Examples/NetworkImageDemo).

## Supported Platforms

You can use `NetworkImage` in the following platforms:

* macOS 10.15+
* iOS 13.0+
* tvOS 13.0+
* watchOS 6.0+

## Usage
A network image downloads and displays an image from a given URL; the download is asynchronous,
and the result is cached both in disk and memory.

You create a network image, in its simplest form, by providing the image URL.

```swift
NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
  .frame(width: 300, height: 200)
```

To manipulate the loaded image, use the `content` parameter.

```swift
NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200")) { image in
  image.resizable().scaledToFill()
}
.frame(width: 150, height: 150)
.clipped()
```

The view displays a standard placeholder that fills the available space until the image loads. You
can specify a custom placeholder by using the `placeholder` parameter.

```swift
NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200")) { image in
  image.resizable().scaledToFill()
} placeholder: {
  Color.yellow // Shown while the image is loaded or an error occurs
}
.frame(width: 150, height: 150)
.clipped()
```

It is also possible to specify a custom fallback placeholder that the view will display if there is
an error or the URL is `nil`.

```swift
NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200")) { image in
  image.resizable().scaledToFill()
} placeholder: {
  ProgressView() // Shown while the image is loaded
} fallback: {
  Image(systemName: "photo") // Shown when an error occurs or the URL is nil
}
.frame(width: 150, height: 150)
.clipped()
.background(Color.yellow)
```

### Using NetworkImageLoader
For other use cases outside the scope of SwiftUI, you can download images directly using the
shared `NetworkImageLoader`. In the following example, a view controller downloads an image
and applies a transformation to it.
  
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

          NetworkImageLoader.shared.image(for: URL(string: "https://picsum.photos/id/237/300/200")!)
              .map { image in
                  // tint the image with a yellow color
                  UIGraphicsImageRenderer(size: image.size).image { _ in
                      image.draw(at: .zero)
                      UIColor.systemYellow.setFill()
                      UIRectFillUsingBlendMode(CGRect(origin: .zero, size: image.size), .multiply)
                  }
              }
              .replaceError(with: UIImage(systemName: "photo.fill")!)
              .receive(on: DispatchQueue.main)
              .sink(receiveValue: { [imageView] image in
                  imageView.image = image
              })
              .store(in: &cancellables)
      }
  }
```

### NetworkImage and Testing
NetworkImage is implemented with testing in mind and provides view modifiers to stub image
responses. This allows you to write synchronous tests, avoiding the use of expectations or waits.
The following example shows how to use this feature with Point-Free's
[SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library.

```swift
final class MyTests: XCTestCase {
    func testImage() {
        let view = NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200")!)
            .scaledToFill()
            .frame(width: 300, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            // Stub a badServerResponse error
            .networkImageLoader(
                .mock(response: Fail(error: URLError(.badServerResponse) as Error))
            )

        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhoneSe)))
    }
}
```

## Installation
You can add NetworkImage to an Xcode project by adding it as a package dependency.
1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
1. Enter `https://github.com/gonzalezreal/NetworkImage` into the package repository URL text field
1. Link **NetworkImage** to your application target

## Other Libraries
* [AsyncImage](https://github.com/V8tr/AsyncImage)
