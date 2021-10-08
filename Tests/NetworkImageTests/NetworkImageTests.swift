#if !os(watchOS) && !os(macOS) && !targetEnvironment(macCatalyst)
    import Combine
    import SnapshotTesting
    import SwiftUI
    import XCTest

    import NetworkImage

    final class NetworkImageTests: XCTestCase {
        #if os(iOS)
            private let layout = SwiftUISnapshotLayout.device(config: .iPhone8)
            private let platformName = "iOS"
        #elseif os(tvOS)
            private let layout = SwiftUISnapshotLayout.device(config: .tv)
            private let platformName = "tvOS"
        #endif

        func testImage() {
            let view = NetworkImage(url: Fixtures.anyImageURL)
                .networkImageLoader(
                    .mock(
                        url: Fixtures.anyImageURL,
                        withResponse: Just(Fixtures.anyImage).setFailureType(to: Error.self)
                    )
                )
                .networkImageScheduler(.immediate)
                .scaledToFill()
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testImageInVerticalStack() {
            let view = VStack {
                NetworkImage(url: Fixtures.anyImageURL)
                    .networkImageLoader(
                        .mock(
                            url: Fixtures.anyImageURL,
                            withResponse: Just(Fixtures.anyImage).setFailureType(to: Error.self)
                        )
                    )
                    .networkImageScheduler(.immediate)
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testEmptyPlaceholder() {
            let testScheduler = DispatchQueue.test
            let view = NetworkImage(url: Fixtures.anyImageURL)
                .networkImageLoader(
                    .mock(
                        url: Fixtures.anyImageURL,
                        withResponse: Just(Fixtures.anyImage)
                            .setFailureType(to: Error.self)
                            .delay(for: .seconds(1), scheduler: testScheduler)
                    )
                )
                .networkImageScheduler(testScheduler.eraseToAnyScheduler())
                .frame(width: 300, height: 300)
                .background(Color.yellow)

            testScheduler.advance()

            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testEmptyFallback() {
            let view = NetworkImage(url: Fixtures.anyImageURL)
                .networkImageLoader(
                    .mock(
                        url: Fixtures.anyImageURL,
                        withResponse: Fail(error: Fixtures.anyError as Error)
                    )
                )
                .networkImageScheduler(.immediate)
                .frame(width: 300, height: 300)
                .background(Color.yellow)

            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        @available(iOS 14.0, tvOS 14.0, *)
        func testCustomPlaceholder() {
            let testScheduler = DispatchQueue.test
            let view = NetworkImage(
                url: Fixtures.anyImageURL,
                placeholder: { ProgressView() }
            )
            .networkImageLoader(
                .mock(
                    url: Fixtures.anyImageURL,
                    withResponse: Fail(error: Fixtures.anyError as Error)
                        .delay(for: .seconds(1), scheduler: testScheduler)
                )
            )
            .networkImageScheduler(testScheduler.eraseToAnyScheduler())
            .frame(width: 300, height: 300)
            .background(Color.yellow)

            testScheduler.advance()

            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        func testCustomFallback() {
            let view = NetworkImage(
                url: Fixtures.anyImageURL,
                fallback: { Text("Failed!").padding() }
            )
            .networkImageLoader(
                .mock(
                    url: Fixtures.anyImageURL,
                    withResponse: Fail(error: Fixtures.anyError as Error)
                )
            )
            .networkImageScheduler(.immediate)
            .frame(width: 300, height: 300)
            .background(Color.yellow)

            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        @available(iOS 14.0, tvOS 14.0, *)
        func testImagePlaceholder() {
            let testScheduler = DispatchQueue.test
            let view = NetworkImage(
                url: Fixtures.anyImageURL,
                placeholderSystemImage: "photo.fill"
            )
            .networkImageLoader(
                .mock(
                    url: Fixtures.anyImageURL,
                    withResponse: Fail(error: Fixtures.anyError as Error)
                        .delay(for: .seconds(1), scheduler: testScheduler)
                )
            )
            .networkImageScheduler(testScheduler.eraseToAnyScheduler())
            .frame(width: 300, height: 300)
            .foregroundColor(Color.primary.opacity(0.5))
            .background(Color.yellow)

            testScheduler.advance()

            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }

        @available(iOS 14.0, tvOS 14.0, *)
        func testImageFallback() {
            let view = NetworkImage(
                url: Fixtures.anyImageURL,
                fallbackSystemImage: "photo.fill"
            )
            .networkImageLoader(
                .mock(
                    url: Fixtures.anyImageURL,
                    withResponse: Fail(error: Fixtures.anyError as Error)
                )
            )
            .networkImageScheduler(.immediate)
            .frame(width: 300, height: 300)
            .foregroundColor(Color.primary.opacity(0.5))
            .background(Color.yellow)

            assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
        }
    }
#endif
