import Foundation

public enum NetworkImageError: Error, Equatable {
  case badStatus(Int)
  case invalidData(Data)
}
