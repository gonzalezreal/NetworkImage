import Foundation

@testable import NetworkImage

enum Fixtures {
  static let source = ImageSource(
    url: URL(string: "https://picsum.photos/id/237/300/200")!
  )
  static let source2x = ImageSource(
    url: URL(string: "https://picsum.photos/id/237/300/200")!, scale: 2
  )
  static let anotherSource = ImageSource(
    url: URL(string: "https://picsum.photos/id/1/200/300")!
  )
  static let imageData = Data(
    base64Encoded: """
      iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42\
      mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=
      """
  )!
  static let image = PlatformImage.decoding(data: imageData, scale: 1)!
  static let okResponse = HTTPURLResponse(
    url: source.url,
    statusCode: 200,
    httpVersion: "HTTP/1.1",
    headerFields: nil
  )!
  static let internalServerErrorResponse = HTTPURLResponse(
    url: source.url,
    statusCode: 500,
    httpVersion: "HTTP/1.1",
    headerFields: nil
  )!
}
