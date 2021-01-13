# NetworkImage
[![CI](https://github.com/gonzalezreal/NetworkImage/workflows/CI/badge.svg)](https://github.com/gonzalezreal/NetworkImage/actions?query=workflow%3ACI)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgonzalezreal%2FNetworkImage%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/gonzalezreal/NetworkImage)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgonzalezreal%2FNetworkImage%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/gonzalezreal/NetworkImage)
[![contact: @gonzalezreal](https://img.shields.io/badge/contact-@gonzalezreal-blue.svg?style=flat)](https://twitter.com/gonzalezreal)

NetworkImage is a Swift package that provides image downloading, caching, and displaying for your SwiftUI apps. It leverages the foundation URLCache, providing persistent and in-memory caches.

You can explore all the capabilities of this package in the [companion demo project](Examples/NetworkImageDemo).

## Supported Platforms

You can use the `NetworkImage` SwiftUI view in the following platforms:

* macOS 11.0+
* iOS 14.0+
* tvOS 14.0+
* watchOS 7.0+

The `ImageDownloader` is available in: 

* macOS 10.15+
* iOS 13.0+
* tvOS 13.0+
* watchOS 6.0+

## Usage
A network image downloads and displays an image from a given URL; the download is asynchronous, and the result is cached both in disk and memory.

You create a network image, in its simplest form, by providing the image URL.

```swift
NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
    .scaledToFit()
```

You can also provide the name of a placeholder image that the view will display while the image is loading or, as a fallback, if an error occurs or the URL is `nil`.

```swift
NetworkImage(
    url: URL(string: "https://picsum.photos/id/237/300/200"),
    placeholderSystemImage: "photo.fill"
)
.scaledToFit()
```

If you want, you can only provide a fallback image. A network image view only displays this image if an error occurs or when the URL is `nil`.

```swift
NetworkImage(
    url: URL(string: "https://picsum.photos/id/237/300/200"),
    fallbackSystemImage: "photo.fill"
)
.scaledToFit()
```

It is also possible to create network images using views to compose the network image's placeholders programmatically.

```swift
NetworkImage(url: movie.posterURL) {
    ProgressView()
} fallback: {
    Text(movie.title)
        .padding()
}
.scaledToFit()
```

### Styling Network Images
You can customize the appearance of network images by creating styles that conform to the `NetworkImageStyle` protocol. To set a specific style for all network images within a view, use the `networkImageStyle(_:)` modifier. In the following example, a custom style adds a grayscale effect to all the network image views within the enclosing `VStack`:

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            NetworkImage(url: URL(string: "https://picsum.photos/id/1025/300/200"))
            NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
        }
        .networkImageStyle(GrayscaleNetworkImageStyle())
    }
}

struct GrayscaleNetworkImageStyle: NetworkImageStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.image
            .resizable()
            .scaledToFit()
            .grayscale(0.99)
    }
}
```

### Using ImageDownloader
For other use cases outside the scope of SwiftUI, you can download images directly using the shared `ImageDownloader`. In the following example, a view controller downloads an image and applies a transformation to it:
  
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
              .replaceError(with: UIImage(systemName: "photo.fill")!)
              .receive(on: DispatchQueue.main)
              .sink(receiveValue: { [imageView] image in
                  imageView.image = image
              })
              .store(in: &cancellables)
      }
  }
```

### NetworkImage and Snapshot Testing
If you use snapshot testing to test your views, you may need NetworkImage to operate **synchronously** during testing, avoiding the use of expectations or waits. To configure a network image view to download its image synchronously, blocking the UI thread,  use the `synchronous()` method. The following example shows how to use this feature with Point-Free's [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library.

```swift
final class MyTests: XCTestCase {
    func testImage() {
        let view = NetworkImage(url: fixtureURL("image.jpg"))
            .synchronous() // download the image synchronously
            .scaledToFill()
            .frame(width: 300, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 8))

        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhoneSe)))
    }
}
```

With the default (asynchronous) behavior, we would have needed to introduce a wait, which would make our test slower.

```swift
assertSnapshot(matching: view, as: .wait(for: 0.25, on: .image(layout: .device(config: .iPhoneSe))))
```

Make sure you only use this feature in your tests and not in production code. Production code must always download images **asynchronously**.

## Installation
You can add NetworkImage to an Xcode project by adding it as a package dependency.
1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
1. Enter `https://github.com/gonzalezreal/NetworkImage` into the package repository URL text field
1. Link **NetworkImage** to your application target

## Other Libraries
* [AsyncImage](https://github.com/V8tr/AsyncImage)
