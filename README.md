# NetworkImage
![Swift 5.2](https://img.shields.io/badge/Swift-5.2-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS+tvOS+watchOS-brightgreen.svg?style=flat)
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![Twitter: @gonzalezreal](https://img.shields.io/badge/twitter-@gonzalezreal-blue.svg?style=flat)](https://twitter.com/gonzalezreal)

**NetworkImage** is a Swift µpackage that provides image downloading and caching for your apps. It leverages the foundation [`URLCache`](https://developer.apple.com/documentation/foundation/urlcache), providing persistent and in-memory caches. 

## Usage

The simplest way to display remote images in your UIKit app is by using `NetworkImageView`. This `UIView` subclass provides a `url` property to configure the image URL, and a `placeholder` property to configure the image that will be displayed when the URL is `nil` or the image fails to load. On top of that, it performs a cross-fade transition when the image takes more than a certain time to load. 

```Swift
class MovieItemCell: UICollectionViewCell {
    // ...
    private lazy var imageView = NetworkImageView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // cancels any ongoing image download and resets the view
        imageView.prepareForReuse()
    }
    
    func configure(with movieItem: MovieItem) {
        // ...
        imageView.url = movieItem.posterURL
        imageView.placeholder = Image(systemName: "film")
    }
}
```

If you need a more customized behavior, like applying transformations to images or providing your custom animations and loading state, you can use the `ImageDownloader` object directly.

```Swift
class MovieItemCell: UICollectionViewCell {
    // ...
    private lazy var imageView = ImageView()
    private var cancellable: AnyCancellable?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
    }
    
    func configure(with movieItem: MovieItem) {
        // ...
        cancellable = imageDownloader.shared.image(for: movieItem.posterURL)
            .map { $0.applySomeFancyEffect() }
            .replaceError(with: Image(systemName: "film")!)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: imageView)
    }
}
```

It is also straightforward to implement a SwiftUI view that displays a remote image, by using the `onReceive` modifier to subscribe to the image(s) emitted by the `ImageDownloader.image(for:)` publisher. 

```Swift
struct ContentView: View {
    @State private var image: UIImage?
    private let placeholder = UIImage(systemName: "photo")!

    var url = URL(string: "https://image.tmdb.org/t/p/w300/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg")!

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
            image.map {
                Image(uiImage: $0)
            }
        }
        .onReceive(
            ImageDownloader.shared.image(for: url)
                .replaceError(with: placeholder)
                .receive(on: DispatchQueue.main)
        ) { image in
            withAnimation {
                self.image = image
            }
        }
    }
}
```

## Installation
**Using the Swift Package Manager**

Add NetworkImage as a dependency to your `Package.swift` file. For more information, see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

```
.package(url: "https://github.com/gonzalezreal/NetworkImage", from: "1.0.0")
```

## Help & Feedback
- [Open an issue](https://github.com/gonzalezreal/NetworkImage/issues/new) if you need help, if you found a bug, or if you want to discuss a feature request.
- [Open a PR](https://github.com/gonzalezreal/NetworkImage/pull/new/master) if you want to make some change to `Reusable`.
- Contact [@gonzalezreal](https://twitter.com/gonzalezreal) on Twitter.
