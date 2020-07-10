//
// NetworkImageView.swift
//
// Copyright (c) 2020 Guille Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if (os(iOS) || os(tvOS)) && canImport(UIKit) && canImport(Combine)
    import Combine
    import UIKit

    @available(iOS 13.0, tvOS 13.0, *)
    open class NetworkImageView: UIView {
        open var placeholder = UIImage(systemName: "photo")
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
                    case .placeholder:
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
