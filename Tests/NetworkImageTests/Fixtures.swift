import Foundation
@testable import NetworkImage

enum Fixtures {
    // Photo by Charles Deluvio (https://unsplash.com/@charlesdeluvio)
    static let anyImageURL = fixtureURL("charles-deluvio-REtZm_TkolU-unsplash.jpg")
    
    static let anyOtherImageURL = URL(string: "https://picsum.photos/id/237/300/200")!
    static let invalidImageURL = fixtureURL("unknown")
    
    static let anyImageResponse = try! Data(contentsOf: anyImageURL)
    static let anyResponse = Data(base64Encoded: "Z29uemFsZXpyZWFs")!
    
    static let anyImage = try! decodeImage(from: anyImageResponse)
    static let anyError = NetworkImageError.badStatus(500)
}

private func fixtureURL(_ fileName: String, file: StaticString = #file) -> URL {
    URL(fileURLWithPath: "\(file)", isDirectory: false)
        .deletingLastPathComponent()
        .appendingPathComponent("__Fixtures__")
        .appendingPathComponent(fileName)
}
