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

    @available(iOS 14.0, tvOS 14.0, *)
    func testDefaultPlaceholder() {
      let view = VStack {
        NetworkImage(url: nil)
          .frame(width: 150, height: 150)
        NetworkImage(url: Fixtures.anyImageURL)
          .frame(width: 150, height: 150)
          .clipped()
          .networkImageLoader(
            .mock(
              url: Fixtures.anyImageURL,
              withResponse: Just(Fixtures.anyImage).setFailureType(to: Error.self)
            )
          )
        NetworkImage(url: Fixtures.anyImageURL, scale: 2)
          .frame(width: 150, height: 150)
          .clipped()
          .networkImageLoader(
            .mock(
              url: Fixtures.anyImageURL,
              scale: 2,
              withResponse: Just(Fixtures.anyImage2x).setFailureType(to: Error.self)
            )
          )
      }

      assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
    }

    @available(iOS 14.0, tvOS 14.0, *)
    func testModifiableContent() {
      func testImage(url: URL?) -> some View {
        NetworkImage(url: url) { image in
          image.resizable().scaledToFill()
        }
        .frame(width: 150, height: 150)
        .clipped()
      }

      let view = VStack {
        testImage(url: nil)
        testImage(url: Fixtures.anyImageURL)
          .networkImageLoader(
            .mock(
              url: Fixtures.anyImageURL,
              withResponse: Just(Fixtures.anyImage).setFailureType(to: Error.self)
            )
          )
        testImage(url: Fixtures.anyImageURL)
          .networkImageLoader(
            .mock(
              url: Fixtures.anyImageURL,
              withResponse: Fail(error: Fixtures.anyError as Error)
            )
          )
      }

      assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
    }

    func testModifiableContentAndCustomPlaceholder() {
      func testImage(url: URL?) -> some View {
        NetworkImage(url: url) { image in
          image.resizable().scaledToFill()
        } placeholder: {
          Color.yellow
        }
        .frame(width: 150, height: 150)
        .clipped()
      }

      let view = VStack {
        testImage(url: nil)
        testImage(url: Fixtures.anyImageURL)
          .networkImageLoader(
            .mock(
              url: Fixtures.anyImageURL,
              withResponse: Just(Fixtures.anyImage).setFailureType(to: Error.self)
            )
          )
        testImage(url: Fixtures.anyImageURL)
          .networkImageLoader(
            .mock(
              url: Fixtures.anyImageURL,
              withResponse: Fail(error: Fixtures.anyError as Error)
            )
          )
      }

      assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
    }

    @available(iOS 14.0, tvOS 14.0, *)
    func testModifiableContentCustomPlaceholderAndFallback() {
      func testImage(url: URL?) -> some View {
        NetworkImage(url: url) { image in
          image.resizable().scaledToFill()
        } placeholder: {
          ProgressView()
        } fallback: {
          Image(systemName: "photo")
        }
        .frame(width: 150, height: 150)
        .clipped()
        .background(Color.yellow)
      }

      let view = VStack {
        testImage(url: nil)
        testImage(url: Fixtures.anyImageURL)
          .networkImageLoader(
            .mock(
              url: Fixtures.anyImageURL,
              withResponse: Empty().setFailureType(to: Error.self)
            )
          )
        testImage(url: Fixtures.anyImageURL)
          .networkImageLoader(
            .mock(
              url: Fixtures.anyImageURL,
              withResponse: Just(Fixtures.anyImage).setFailureType(to: Error.self)
            )
          )
        testImage(url: Fixtures.anyImageURL)
          .networkImageLoader(
            .mock(
              url: Fixtures.anyImageURL,
              withResponse: Fail(error: Fixtures.anyError as Error)
            )
          )
      }

      assertSnapshot(matching: view, as: .image(layout: layout), named: platformName)
    }
  }
#endif
