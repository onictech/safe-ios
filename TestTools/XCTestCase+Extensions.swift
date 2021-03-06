//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

// MARK: - Window Extensions

extension XCTestCase {

    func createWindow(_ controller: UIViewController) {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        window.rootViewController?.present(controller, animated: false)
        delay()
        XCTAssertNotNil(controller.view.window)
    }

    func addToWindow(_ view: UIView) {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.addSubview(view)
    }

}

// MARK: - Wait Extensions

extension XCTestCase {

    func waitUntil(closure: () -> Bool,
                   timeout: TimeInterval = 1,
                   file: String = #file,
                   line: Int = #line) {
        var time: TimeInterval = 0
        let step: TimeInterval = 0.1
        let loop = RunLoop.current
        var result = closure()
        while !result && time < timeout {
            loop.run(until: Date().addingTimeInterval(step))
            time += step
            result = closure()
        }
        if !result {
            recordFailure(withDescription: "Waiting failed", inFile: file, atLine: line, expected: true)
        }
    }

    func waitUntil(_ condition: @autoclosure () -> Bool,
                   timeout: TimeInterval = 1,
                   file: String = #file,
                   line: Int = #line) {
        waitUntil(closure: condition, timeout: timeout, file: file, line: line)
    }

    func waitUntil(_ element: XCUIElement,
                   timeout: TimeInterval = 15,
                   file: String = #file,
                   line: Int = #line,
                   _ conditions: Predicate ...) {
        let predicate = NSPredicate(format: conditions.map { $0.rawValue }.joined(separator: " AND "))
        let expectation = self.expectation(for: predicate, evaluatedWith: element, handler: nil)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        switch result {
        case .completed:
            return
        default:
            recordFailure(withDescription: "Conditions \(predicate) failed for \(element) after \(timeout) seconds",
                inFile: file, atLine: line, expected: true)
        }
    }

}


enum Predicate: String {
    case exists = "exists == true"
    case doesNotExist = "self.exists == false"
    case selected = "isSelected == true"
    case hittable = "isHittable == true"
    case notHittable = "isHittable == false"
}
