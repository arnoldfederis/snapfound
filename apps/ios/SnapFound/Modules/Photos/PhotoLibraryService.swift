@preconcurrency import Photos
import SwiftUI

final class PhotoLibraryService {
  static let shared = PhotoLibraryService()
  private init() {}

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

  /// Returns JPEG Data — Sendable-safe for actor boundary crossing.
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

      // nonisolated(unsafe): Photos serialises callbacks per request;
      // no actual data race possible.
      nonisolated(unsafe) var delivered = false

      PHImageManager.default().requestImage(
        for: asset,
        targetSize: PHImageManagerMaximumSize,
        contentMode: .aspectFit,
        options: options
      ) { image, info in
        let isDegraded =
          (info?[PHImageResultIsDegradedKey] as? Bool) == true
        guard !isDegraded, !delivered else { return }
        delivered = true

        if let error = info?[PHImageErrorKey] as? Error {
          continuation.resume(throwing: error)
        } else if let image,
          let data = image.jpegData(compressionQuality: 0.95)
        {
          continuation.resume(returning: data)
        } else {
          continuation.resume(
            throwing: PhotoLibraryError.imageLoadFailed
          )
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
      options.isNetworkAccessAllowed = false

      nonisolated(unsafe) var delivered = false

      PHImageManager.default().requestImage(
        for: asset,
        targetSize: CGSize(width: 300, height: 300),
        contentMode: .aspectFill,
        options: options
      ) { image, info in
        let isDegraded =
          (info?[PHImageResultIsDegradedKey] as? Bool) == true
        guard !isDegraded, !delivered else { return }
        delivered = true

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

  /// Loads UIImage for display — call from MainActor only.
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

      nonisolated(unsafe) var delivered = false

      PHImageManager.default().requestImage(
        for: asset,
        targetSize: targetSize,
        contentMode: .aspectFit,
        options: options
      ) { image, info in
        let isDegraded =
          (info?[PHImageResultIsDegradedKey] as? Bool) == true
        guard !isDegraded, !delivered else { return }
        delivered = true

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
}

enum PhotoLibraryError: LocalizedError {
  case assetNotFound(String)
  case imageLoadFailed

  var errorDescription: String? {
    switch self {
    case .assetNotFound(let id): "Photo asset not found: \(id)"
    case .imageLoadFailed: "Failed to load image from Photos"
    }
  }
}
