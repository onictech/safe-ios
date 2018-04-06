//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class ApplicationServiceRegistryTests: XCTestCase {

    func test_authenticationService_exists() {
        XCTAssertNotNil(ApplicationServiceRegistry.authenticationService)
        XCTAssertNotNil(ApplicationServiceRegistry.clock)
    }

}
