#if (os(iOS) || os(tvOS)) && canImport(UIKit) && canImport(Combine)
    import Combine
    import UIKit

    /// A view that displays a remote image.
    ///
    /// A network image view downloads and displays an image from a given URL.
    /// The download is asynchronous, and the result is cached both in disk and memory.
    ///
    /// You can specify a placeholder image that will be displayed if the download fails or the URL is `nil`.
    ///
    /// When there is no cached image for the given URL, and the download takes more than a specific time,
    /// the view performs a cross-fade transition between the placeholder and the result.
    ///
    /// As a basic example, consider a UICollectionView subclass that displays a movie poster:
    ///
    ///     class MoviePosterCell: UICollectionViewCell {
    ///         private lazy var imageView = NetworkImageView()
    ///
    ///         override func prepareForReuse() {
    ///             super.prepareForReuse()
    ///             // cancels any ongoing image download and resets the view
    ///             imageView.prepareForReuse()
    ///         }
    ///
    ///         func configure(with movie: Movie) {
    ///             imageView.url = movie.posterURL
    ///             imageView.placeholder = Image(systemName: "film")
    ///         }
    ///
    ///         ...
    ///     }
    @available(iOS 13.0, tvOS 13.0, *)
    open class NetworkImageView: UIView {
        /// Placeholder image that will be used when `url` is `nil` or the download fails.
        open var placeholder = UIImage(systemName: "photo")

        /// The URL for the image.
        open var url: URL? {
            didSet { store.send(.didSetURL(url)) }
        }

        override open var intrinsicContentSize: CGSize {
            imageView.intrinsicContentSize
        }

        private let store = NetworkImageStore()
        private lazy var imageView = UIImageView()
        private var cancellable: AnyCancellable?

        override public init(frame: CGRect) {
            super.init(frame: frame)
            setUp()
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            setUp()
        }

        /// Resets the view and cancels any ongoing download.
        open func prepareForReuse() {
            store.send(.prepareForReuse)
        }

        override open func layoutSubviews() {
            super.layoutSubviews()
            imageView.frame = bounds
        }
    }

    @available(iOS 13.0, tvOS 13.0, *)
    private extension NetworkImageView {
        enum Constants {
            static let animationThreshold: TimeInterval = 0.1
        }

        func setUp() {
            #if os(iOS)
                backgroundColor = .secondarySystemBackground
                tintColor = .systemFill
            #endif

            imageView.clipsToBounds = true
            addSubview(imageView)

            cancellable = store.$state
                .sink { [weak self] state in
                    guard let self = self else { return }

                    switch state {
                    case .notRequested, .loading:
                        self.imageView.image = nil
                    case let .image(image, elapsedTime):
                        self.imageView.setImage(
                            image,
                            contentMode: .scaleAspectFill,
                            animated: elapsedTime >= Constants.animationThreshold
                        )
                    case .failed:
                        self.imageView.setImage(self.placeholder, contentMode: .center)
                    }
                }
        }
    }

    @available(iOS 10.0, tvOS 10.0, *)
    private extension UIImageView {
        enum Constants {
            static let transitionDuration: TimeInterval = 0.25
        }

        func setImage(_ image: UIImage?, contentMode: UIView.ContentMode, animated: Bool) {
            if animated {
                UIView.transition(
                    with: self,
                    duration: Constants.transitionDuration,
                    options: [.beginFromCurrentState, .curveEaseInOut, .transitionCrossDissolve],
                    animations: {
                        self.setImage(image, contentMode: contentMode)
                    }
                )
            } else {
                setImage(image, contentMode: contentMode)
            }
        }

        func setImage(_ image: UIImage?, contentMode: UIView.ContentMode) {
            self.contentMode = contentMode
            self.image = image
        }
    }
#endif
