import NetworkImage
import SwiftUI

struct ImageLoaderExampleView: UIViewControllerRepresentable {
  func makeUIViewController(context _: Context) -> ImageLoaderViewController {
    ImageLoaderViewController()
  }

  func updateUIViewController(_: ImageLoaderViewController, context _: Context) {}
}

class ImageLoaderViewController: UIViewController {
  private let imageLoader: NetworkImageLoader = .default
  private lazy var imageView = UIImageView()
  private var task: Task<Void, Never>?

  deinit {
    self.task?.cancel()
  }

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
    self.task = Task {
      await self.loadImage()
    }
  }

  private func loadImage() async {
    do {
      let image = try await self.imageLoader.image(
        with: URL(string: "https://picsum.photos/id/237/300/200")!
      )
      self.imageView.image = UIGraphicsImageRenderer(size: image.size).image { _ in
        image.draw(at: .zero)
        UIColor.systemYellow.setFill()
        UIRectFillUsingBlendMode(CGRect(origin: .zero, size: image.size), .multiply)
      }
    } catch {
      self.imageView.image = UIImage(systemName: "photo.fill")!
    }
  }
}
