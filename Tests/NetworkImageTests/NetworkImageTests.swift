#if canImport(SwiftUI) && !os(macOS) && !targetEnvironment(macCatalyst)
    import SnapshotTesting
    import SwiftUI
    import XCTest

    import NetworkImage

    @available(iOS 14.0, tvOS 14.0, *)
    final class NetworkImageTests: XCTestCase {
        #if os(iOS)
            private let layout = SwiftUISnapshotLayout.device(config: .iPhone8)
            private let platformName = "iOS"
        #elseif os(tvOS)
            private let layout = SwiftUISnapshotLayout.device(config: .tv)
            private let platformName = "tvOS"
        #endif

        override class func setUp() {
            isSynchronous = true
        }

        func testImage() {
            let view = NetworkImage(url: Fixtures.anyImageURL)
                .scaledToFill()
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testEmptyPlaceholders() {
            struct TestView: View {
                var body: some View {
                    NetworkImage(url: Fixtures.invalidImageURL)
                        .frame(width: 300, height: 300)
                        .background(Color.yellow)
                }
            }

            isSynchronous = false
            assertSnapshot(matching: TestView(), as: .image(layout: layout), named: "placeholder." + platformName)

            isSynchronous = true
            assertSnapshot(matching: TestView(), as: .image(layout: layout), named: "fallback." + platformName)
        }

        func testCustomPlaceholders() {
            struct TestView: View {
                var body: some View {
                    NetworkImage(url: Fixtures.invalidImageURL) {
                        ProgressView()
                    } fallback: {
                        Text("Failed!").padding()
                    }
                    .frame(width: 300, height: 300)
                    .background(Color.yellow)
                }
            }

            isSynchronous = false
            assertSnapshot(matching: TestView(), as: .image(layout: layout), named: "placeholder." + platformName)

            isSynchronous = true
            assertSnapshot(matching: TestView(), as: .image(layout: layout), named: "fallback." + platformName)
        }

        func testPlaceholderImage() {
            struct TestView: View {
                var body: some View {
                    NetworkImage(
                        url: Fixtures.invalidImageURL,
                        placeholderSystemImage: "photo.fill"
                    )
                    .frame(width: 300, height: 300)
                    .foregroundColor(Color.primary.opacity(0.5))
                    .background(Color.yellow)
                }
            }

            isSynchronous = false
            assertSnapshot(matching: TestView(), as: .image(layout: layout), named: "placeholder." + platformName)

            isSynchronous = true
            assertSnapshot(matching: TestView(), as: .image(layout: layout), named: "fallback." + platformName)
        }

        func testFallbackImage() {
            struct TestView: View {
                var body: some View {
                    NetworkImage(
                        url: Fixtures.invalidImageURL,
                        fallbackSystemImage: "photo.fill"
                    )
                    .frame(width: 300, height: 300)
                    .foregroundColor(Color.primary.opacity(0.5))
                    .background(Color.yellow)
                }
            }

            isSynchronous = false
            assertSnapshot(matching: TestView(), as: .image(layout: layout), named: "placeholder." + platformName)

            isSynchronous = true
            assertSnapshot(matching: TestView(), as: .image(layout: layout), named: "fallback." + platformName)
        }
    }
#endif
