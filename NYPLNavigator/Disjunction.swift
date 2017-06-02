import Foundation

enum Disjunction<A, B> {
  case first(value: A)
  case second(value: B)
  case both(first: A, second: B)

  var count: Int {
    switch self {
    case .first:
      return 1
    case .second:
      return 1
    case .both:
      return 2
    }
  }
}
