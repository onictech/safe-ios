//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe

class ReviewSafeViewControllerTests: XCTestCase {

    let controller = ReviewSafeViewController()

    func test_canCreate() {
        XCTAssertNotNil(controller)
    }

}
