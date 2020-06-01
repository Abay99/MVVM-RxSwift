import Foundation

public func example(_ rxOperator: String, action: ()->()) {
    print("<---- Example of \(rxOperator) -----")
    action()
}
