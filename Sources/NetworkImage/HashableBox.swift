import Foundation

final class HashableBox<Value: Hashable>: NSObject {
  let value: Value

  init(_ value: Value) {
    self.value = value
  }

  override func isEqual(_ object: Any?) -> Bool {
    guard let other = object as? HashableBox<Value> else { return false }
    return self.value == other.value
  }

  override var hash: Int {
    self.value.hashValue
  }
}
