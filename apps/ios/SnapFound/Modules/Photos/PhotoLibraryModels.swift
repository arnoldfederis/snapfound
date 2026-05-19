import Foundation

struct PhotoAsset {
  let localIdentifier: String
  let creationDate: Date
  let pixelWidth: Int
  let pixelHeight: Int
}

enum PhotosAuthStatus {
  case notDetermined
  case authorized
  case limited
  case denied
  case restricted
}
