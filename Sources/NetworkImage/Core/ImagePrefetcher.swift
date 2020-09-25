#if canImport(Combine)
    import Combine
    import Foundation

    /// An `ImagePrefetcher` object and be used to preload images and warm the caches up,
    /// providing a smoother user experience when scrolling through collection views.
    ///
    /// You can use an `ImagePrefetcher` instance to implement a prefetch data source in a
    /// collection view:
    ///
    ///     class MovieListViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    ///         private lazy var imagePrefetcher = ImagePrefetcher()
    ///         override func viewDidLoad() {
    ///             super.viewDidLoad()
    ///             collectionView.prefetchDataSource = self
    ///         }
    ///
    ///         func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    ///             imagePrefetcher.prefetchImages(with: imageURLs(for: indexPaths))
    ///         }
    ///
    ///         func collectionView(_: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    ///             imagePrefetcher.cancelPrefetchingImages(with: imageURLs(for: indexPaths))
    ///         }
    ///
    ///         func imageURLs(for indexPaths: [IndexPath]) -> Set<URL> {
    ///             Set(
    ///                 indexPaths.map {
    ///                     viewModel.item(at: $0)
    ///                 }
    ///                 .compactMap(\.imageURL)
    ///             )
    ///         }
    ///     }
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public final class ImagePrefetcher {
        private let session: URLSession
        private var cancellables: [URL: AnyCancellable] = [:]

        public init(session: URLSession = .imageLoading) {
            self.session = session
        }

        public func prefetchImages(with urls: Set<URL>) {
            assert(Thread.isMainThread)

            for url in urls where !cancellables.keys.contains(url) {
                cancellables[url] = session.dataTaskPublisher(for: url)
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            }
        }

        public func cancelPrefetchingImages(with urls: Set<URL>) {
            assert(Thread.isMainThread)

            for url in urls {
                cancellables.removeValue(forKey: url)
            }
        }
    }
#endif
