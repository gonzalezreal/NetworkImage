import Foundation

@testable import NetworkImage

enum Fixtures {
  static let anyImageURL = URL(string: "https://picsum.photos/id/237/300/200")!

  // Photo by Charles Deluvio (https://unsplash.com/@charlesdeluvio)
  static let anyImageResponse = try! Data(
    contentsOf: fixtureURL("charles-deluvio-REtZm_TkolU-unsplash.jpg")
  )
  static let anyResponse = Data(base64Encoded: "Z29uemFsZXpyZWFs")!

  static let anyImage = try! decodeImage(from: anyImageResponse, scale: 1)
  static let anyError = NetworkImageError.badStatus(500)
}

private func fixtureURL(_ fileName: String, file: StaticString = #file) -> URL {
  URL(fileURLWithPath: "\(file)", isDirectory: false)
    .deletingLastPathComponent()
    .appendingPathComponent("__Fixtures__")
    .appendingPathComponent(fileName)
}
