#if canImport(SwiftUI) && !os(macOS) && !targetEnvironment(macCatalyst)
    import SnapshotTesting
    import SwiftUI
    import XCTest

    import NetworkImage

    @available(iOS 14.0, tvOS 14.0, *)
    final class NetworkImageTests: XCTestCase {
        struct RoundedImageStyle: NetworkImageStyle {
            var width: CGFloat?
            var height: CGFloat?

            func makeBody(state: NetworkImageState) -> some View {
                ZStack {
                    Color.secondary

                    switch state {
                    case .loading:
                        EmptyView()
                    case let .image(image, _):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failed:
                        Image(systemName: "photo")
                            .foregroundColor(Color.primary.opacity(0.5))
                    }
                }
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }

        #if os(iOS)
            private let layout = SwiftUISnapshotLayout.device(config: .iPhone8)
            private let platformName = "iOS"
        #elseif os(tvOS)
            private let layout = SwiftUISnapshotLayout.device(config: .tv)
            private let platformName = "tvOS"
        #endif

        // Photo by Charles Deluvio (https://unsplash.com/@charlesdeluvio)
        private let imageURL = fixtureURL("charles-deluvio-REtZm_TkolU-unsplash.jpg")

        func testLoading() {
            NetworkImage.isSynchronous = false
            let view = NetworkImage(url: imageURL)
                .frame(width: 200, height: 300)
            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testImage() {
            NetworkImage.isSynchronous = true
            let view = NetworkImage(url: imageURL)
                .frame(width: 200, height: 300)
            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testFailed() {
            NetworkImage.isSynchronous = true
            let view = NetworkImage(url: fixtureURL("unknown"))
                .frame(width: 200, height: 300)
            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testResizableNetworkImageStyle() {
            NetworkImage.isSynchronous = true
            let view = NetworkImage(url: imageURL)
                .frame(width: 200, height: 200)
                .networkImageStyle(
                    ResizableNetworkImageStyle(
                        backgroundColor: .yellow,
                        contentMode: .fit
                    )
                )
            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testCustomStyleLoading() {
            NetworkImage.isSynchronous = false
            let view = NetworkImage(url: imageURL)
                .networkImageStyle(RoundedImageStyle(width: 200, height: 200))
            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testCustomStyleImage() {
            NetworkImage.isSynchronous = true
            let view = NetworkImage(url: imageURL)
                .networkImageStyle(RoundedImageStyle(width: 200, height: 200))
            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testCustomStyleFailed() {
            NetworkImage.isSynchronous = true
            let view = NetworkImage(url: fixtureURL("unknown"))
                .networkImageStyle(RoundedImageStyle(width: 200, height: 200))
            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }
    }

    private func fixtureURL(_ fileName: String, file: StaticString = #file) -> URL {
        URL(fileURLWithPath: "\(file)", isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__")
            .appendingPathComponent(fileName)
    }
#endif
