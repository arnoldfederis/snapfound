@preconcurrency import Photos
import SwiftUI
internal import UIKit

final class PhotoLibraryService {
  static let shared = PhotoLibraryService()
  private init() {}

  private final class RequestState {
    var didResume = false
  }

  private let photosErrorDomain = PHPhotosError.errorDomain

  var authorizationStatus: PhotosAuthStatus {
    switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
    case .notDetermined: .notDetermined
    case .authorized: .authorized
    case .limited: .limited
    case .denied: .denied
    case .restricted: .restricted
    @unknown default: .denied
    }
  }

  func requestAuthorization() async -> PhotosAuthStatus {
    switch await PHPhotoLibrary.requestAuthorization(for: .readWrite) {
    case .notDetermined: .notDetermined
    case .authorized: .authorized
    case .limited: .limited
    case .denied: .denied
    case .restricted: .restricted
    @unknown default: .denied
    }
  }

  func fetchScreenshots(limit: Int? = nil) -> [PhotoAsset] {
    let options = PHFetchOptions()
    options.predicate = NSPredicate(
      format: "mediaSubtype & %d != 0",
      PHAssetMediaSubtype.photoScreenshot.rawValue
    )
    options.sortDescriptors = [
      NSSortDescriptor(key: "creationDate", ascending: false)
    ]
    if let limit { options.fetchLimit = limit }

    var assets: [PhotoAsset] = []
    PHAsset.fetchAssets(with: .image, options: options).enumerateObjects {
      asset,
      _,
      _ in
      assets.append(
        PhotoAsset(
          localIdentifier: asset.localIdentifier,
          creationDate: asset.creationDate ?? Date(),
          pixelWidth: asset.pixelWidth,
          pixelHeight: asset.pixelHeight
        )
      )
    }
    return assets
  }

  func fetchScreenshot(localIdentifier: String) -> PhotoAsset? {
    let result = PHAsset.fetchAssets(
      withLocalIdentifiers: [localIdentifier],
      options: nil
    )
    guard let asset = result.firstObject,
      asset.mediaType == .image,
      asset.mediaSubtypes.contains(.photoScreenshot)
    else {
      return nil
    }

    return PhotoAsset(
      localIdentifier: asset.localIdentifier,
      creationDate: asset.creationDate ?? Date(),
      pixelWidth: asset.pixelWidth,
      pixelHeight: asset.pixelHeight
    )
  }

  /// Returns JPEG Data - Sendable-safe for actor boundary crossing.
  func loadFullImageData(for assetID: String) async throws -> Data {
    let result = PHAsset.fetchAssets(
      withLocalIdentifiers: [assetID],
      options: nil
    )
    guard let asset = result.firstObject else {
      throw PhotoLibraryError.assetNotFound(assetID)
    }

    return try await withCheckedThrowingContinuation { continuation in
      let options = PHImageRequestOptions()
      options.deliveryMode = .highQualityFormat
      options.isNetworkAccessAllowed = true
      options.isSynchronous = false
      options.version = .current

      let state = RequestState()

      PHImageManager.default().requestImageDataAndOrientation(
        for: asset,
        options: options
      ) { data, _, _, info in
        guard !state.didResume else { return }

        if let error = info?[PHImageErrorKey] as? NSError {
          state.didResume = true
          continuation.resume(
            throwing: self.mapImageRequestError(error, assetID: assetID, info: info))
        } else if let isCancelled = info?[PHImageCancelledKey] as? Bool, isCancelled {
          state.didResume = true
          continuation.resume(throwing: PhotoLibraryError.imageLoadFailed)
        } else if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool, isInCloud {
          state.didResume = true
          continuation.resume(throwing: PhotoLibraryError.cloudAssetUnavailableOffline(assetID))
        } else if let data {
          state.didResume = true
          continuation.resume(returning: data)
        } else {
          state.didResume = true
          continuation.resume(throwing: PhotoLibraryError.imageLoadFailed)
        }
      }
    }
  }

  func loadThumbnailData(for assetID: String) async throws -> Data {
    let result = PHAsset.fetchAssets(
      withLocalIdentifiers: [assetID],
      options: nil
    )
    guard let asset = result.firstObject else {
      throw PhotoLibraryError.assetNotFound(assetID)
    }

    return try await withCheckedThrowingContinuation { continuation in
      let options = PHImageRequestOptions()
      options.deliveryMode = .opportunistic
      options.isNetworkAccessAllowed = true

      let state = RequestState()

      PHImageManager.default().requestImage(
        for: asset,
        targetSize: CGSize(width: 300, height: 300),
        contentMode: .aspectFill,
        options: options
      ) { image, info in
        let isDegraded =
          (info?[PHImageResultIsDegradedKey] as? Bool) == true
        guard !isDegraded, !state.didResume else { return }
        state.didResume = true

        if let image, let data = image.jpegData(compressionQuality: 0.7) {
          continuation.resume(returning: data)
        } else {
          continuation.resume(
            throwing: PhotoLibraryError.imageLoadFailed
          )
        }
      }
    }
  }

  /// Loads UIImage for display - call from MainActor only.
  func loadDisplayImage(for assetID: String, targetSize: CGSize) async throws
    -> UIImage
  {
    let result = PHAsset.fetchAssets(
      withLocalIdentifiers: [assetID],
      options: nil
    )
    guard let asset = result.firstObject else {
      throw PhotoLibraryError.assetNotFound(assetID)
    }

    return try await withCheckedThrowingContinuation { continuation in
      let options = PHImageRequestOptions()
      options.deliveryMode = .highQualityFormat
      options.isNetworkAccessAllowed = true

      let state = RequestState()

      PHImageManager.default().requestImage(
        for: asset,
        targetSize: targetSize,
        contentMode: .aspectFit,
        options: options
      ) { image, info in
        let isDegraded =
          (info?[PHImageResultIsDegradedKey] as? Bool) == true
        guard !isDegraded, !state.didResume else { return }
        state.didResume = true

        if let error = info?[PHImageErrorKey] as? Error {
          continuation.resume(throwing: error)
        } else if let image {
          continuation.resume(returning: image)
        } else {
          continuation.resume(
            throwing: PhotoLibraryError.imageLoadFailed
          )
        }
      }
    }
  }

  @MainActor
  func openPhotosApp() async -> Bool {
    for urlString in ["photos://", "photos-redirect://"] {
      guard let url = URL(string: urlString) else { continue }
      if await openURL(url) { return true }
    }
    return false
  }

  @MainActor
  private func openURL(_ url: URL) async -> Bool {
    await withCheckedContinuation { continuation in
      UIApplication.shared.open(url, options: [:]) { didOpen in
        continuation.resume(returning: didOpen)
      }
    }
  }

  private func mapImageRequestError(
    _ error: NSError,
    assetID: String,
    info: [AnyHashable: Any]?
  ) -> Error {
    if error.domain == photosErrorDomain {
      if error.code == PHPhotosError.Code.networkAccessRequired.rawValue
        || error.code == PHPhotosError.Code.networkError.rawValue
      {
        return PhotoLibraryError.cloudAssetUnavailableOffline(assetID)
      }
    }

    if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool, isInCloud {
      return PhotoLibraryError.cloudAssetUnavailableOffline(assetID)
    }

    return error
  }
}

enum PhotoLibraryError: LocalizedError {
  case assetNotFound(String)
  case cloudAssetUnavailableOffline(String)
  case imageLoadFailed

  var errorDescription: String? {
    switch self {
    case .assetNotFound(let id): "Photo asset not found: \(id)"
    case .cloudAssetUnavailableOffline:
      "This screenshot is stored in iCloud and couldn't be downloaded right now."
    case .imageLoadFailed: "Failed to load image from Photos"
    }
  }
}
