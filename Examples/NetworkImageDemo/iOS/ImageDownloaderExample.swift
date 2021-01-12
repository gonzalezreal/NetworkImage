import Combine
import NetworkImage
import SwiftUI

struct ImageDownloaderExampleView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> ImageDownloaderViewController {
        ImageDownloaderViewController()
    }

    func updateUIViewController(_: ImageDownloaderViewController, context _: Context) {}
}

class ImageDownloaderViewController: UIViewController {
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
